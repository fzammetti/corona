<?php

error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'service.log');

processRequest($_SERVER);


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Process an incoming request.
 *
 * @param array $inServer The global _SERVER object.
 */
function processRequest($inServer) {

  error_log('processRequest()');

  // Our database connection.
  $pdo = null;

  try {

    // We only handle POST requests, all others are ignored.
    $httpMethod = $inServer['REQUEST_METHOD'];
    if ($httpMethod !== 'POST') {
      error_log('Incorrect HTTP method: ' . $httpMethod);
      return;
    }

    // A valid request will always be at least 22 characters long (apiVersion[1]+cmd[1]+username[10]+password[10]) even
    // if the username and password are blank.
    $postBody = file_get_contents('php://input');
    $postBodyLength = strlen($postBody);
    if ($postBodyLength < 22) {
      error_log('Incorrect body length: ' . $postBodyLength);
      return;
    }

    // Make sure we got a valid API version and command.
    $apiVersion = substr($postBody, 0, 1);
    $cmd = substr($postBody, 1, 1);
    error_log('apiVersion: ' . $apiVersion);
    error_log('cmd: ' . $cmd);
    if ($apiVersion !== '1') {
      error_log('Invalid API version: ' . $apiVersion);
      return;
    }
    if ($cmd !== 'a' && $cmd !== 'g' && $cmd !== 'r' && $cmd !== 's' && $cmd !== 'u' && $cmd!== 'p') {
      error_log('Invalid cmd: ' . $cmd);
      return;
    }

    // The eventual response, returned to the client.
    $serverResponse = '';

    // One quick bit of "shortcut" logic: if the command requested is the 'p'ing command then we don't even need a
    // database connection, so we can skip some work and keep resource utilization as light as possible.
    if ($cmd === 'p') {

      // Ping requested.
      $serverResponse = ping();

    } else {

      // Ok, the request appears to be valid, get the rest of the pertinent information.
      $username = trim(substr($postBody, 2, 10));
      $password = trim(substr($postBody, 12, 10));
      error_log('username: ' . $username);
      error_log('password: ' . $password);

      // Get ready for database work.
      $pdo = new PDO('mysql:host=localhost;dbname=XXX', 'XXX', 'XXX');
      $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

      // Validate the user for any command other than 'r' (since that obviously doesn't apply during registration).
      if ($cmd !== 'r') {
        $stmt = $pdo->prepare('SELECT username FROM users WHERE username=:username AND password=:password');
        $stmt->execute([':username'=>$username, ':password'=>$password]);
        $row = $stmt->fetch();
        $stmt = null;
        if (empty($row)) {
          error_log('User invalid: ' . $username);
          return;
        }
      }

      // Now get the command payload.
      $payload = substr($postBody, 22);
      error_log('payload: ' . $payload);

      // Now process the command.
      switch ($cmd) {
        case 'g':
          $serverResponse = getMatchStatus($pdo, $username);
        break;
        case 'u':
          $serverResponse = updateMatchStatus($pdo, $username, $payload);
        break;
        case 's':
          $serverResponse = sendInvitation($pdo, $username, $payload);
        break;
        case 'a':
          $serverResponse = acceptInvitation($pdo, $username, $payload);
        break;
        case 'r':
          $serverResponse = register($pdo, $payload);
        break;
        default:
          // It should be impossible to reach this case!
          error_log('Default command branch: ' . $cmd);
        break;
      } /* End cmd switch. */

    } /* End check for ping command. */

    // Send the response back, whatever it may be (note that exceptions in command handler functions results in
    // an empty response) with the identifying prefix code prepended.
    error_log('Response: ' . $serverResponse);
    echo 'Bc' . $serverResponse;

  } catch (PDOException $inPDOException) {
    error_log(
      'EXCEPTION: Creating PDO object: ' . $inPDOException->getMessage() . ' (Code: ' . $inPDOException->getCode() . ')'
    );
  } catch (Exception $inException) {
    error_log('EXCEPTION: Unknown: ' . $inException->getMessage() . ' (Code: ' . $inException->getCode() . ')');
  } finally {
    if (!empty($pdo)) {
      $pdo = null;
    }
  }

} /* End processRequest(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Ping.  Called to get high-level metadata about the game.
 *
 * @return string Returns an object in the form
 *                  VVW
 *                where
 *                  VV .. The most current version of the game available (implied decimal between the digits, so 10
 *                        means 1.0).
 *                  W ... A message to return to the caller to display immediately.  The length of this can be anything
 *                        so this needs to always be the final part of the response and it must always begin at a
 *                        known offset position (currently 5, because 2 for the prefix code and 2 for the version
 *                        come before it).
 */
function ping() {

  try {

    error_log('ping()');

    return '10';

  } catch (Exception $inException) {
    error_log('EXCEPTION: ping(): ' . $inException->getMessage());
    return '';
  }

} /* End ping(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Register.  Called to register a new username.
 *
 * POST body: '1r__________----------AAAAAAAAAABBBBBBBBBB'.
 *
 * Payload description:
 *   AAAAAAAAAA .. Username (right-padded with spaces).
 *   BBBBBBBBBB .. Password (right-padded with spaces).
 *
 * @param  pdo    $inPDO      A PDO object to execute database queries against.
 * @param  string $inPayload  Payload from the POST body.
 * @return string               0 = Successful registration.
 *                              1 = Username already taken and password WAS NOT correct (existing user entered the
 *                                  wrong password, or new user selecting a taken username).
 *                              2 = Username already taken and password WAS correct (existing user logging in).
 */
function register($inPDO, $inPayload) {

  try {

    error_log('register()');

    // Validate payload length.
    $payloadLength = strlen($inPayload);
    if ($payloadLength != 20) {
      error_log('Payload incorrect length: ' . $payloadLength);
      return '';
    }

    // Pull data out of payload.
    $username = trim(substr($inPayload, 0, 10));
    $password = trim(substr($inPayload, 10));
    error_log('Payload username: ' . $username);
    error_log('Payload password: ' . $password);

    // Now see if the username is already taken.
    $stmt = $inPDO->prepare('SELECT username, password FROM users WHERE username=:username');
    $stmt->execute([':username'=>$username]);
    $row = $stmt->fetch();
    $stmt->closeCursor();
    $stmt = null;

    if (empty($row['username'])) {

      // It's not taken, so go ahead and register this user.
      $stmt = $inPDO->prepare('INSERT INTO users (username, password) VALUES (:username, :password)');
      $stmt->execute([':username'=>$username, ':password'=>$password]);
      $stmt = null;
      error_log('Username ' . $username . ' registered');
      return '0';

    } else {

      // Username was found, so this could either be an existing user logging in or simply a new user choosing a
      // taken username.  So, next step is to check the password.
      if ($row['password'] === $password) {
        error_log('Username ' . $username . ' already taken and password WAS correct (existing user login)');
        return '2';
      } else {
        error_log('Username ' . $username . ' already taken and password WAS NOT correct');
        return '1';
      }

    }

  } catch (Exception $inException) {
    error_log('EXCEPTION: register(): ' . $inException->getMessage());
    return '';
  }

} /* End register(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Send Invitation.  Called to invite someone to a match.  This essentially creates a match.
 *
 * POST body: '1s__________----------AAAAAAAAAABC'.
 *
 * Payload description:
 *   AAAAAAAAAA .... Opponent username (right-padded with spaces).
 *   B ............. Number of rounds (1-5).
 *   C ............. Number of games per round (1-5).
 *
 * @param  pdo    $inPDO      A PDO object to execute database queries against.
 * @param  string $inUsername The username passed in, if any (not the one in the payload, if any).
 * @param  string $inPayload  Payload from the POST body.
 * @return string             A list of matches (see getMatchStatus for details), or '1' if the user isn't found, or
 *                            empty string for any other invalid condition.
 */
function sendInvitation($inPDO, $inUsername, $inPayload) {

  try {

    error_log('sendInvitation()');

    // Validate payload length.
    $payloadLength = strlen($inPayload);
    if ($payloadLength != 12) {
      error_log('Payload incorrect length: ' . $payloadLength);
      return '';
    }

    // Pull data out of payload.
    $opponentUsername = trim(substr($inPayload, 0, 10));
    $numRounds = trim(substr($inPayload, 10, 1));
    $numGamesPerRound = trim(substr($inPayload, 11, 1));
    error_log('opponentUsername: ' . $opponentUsername);
    error_log('numRounds: ' . $numRounds);
    error_log('numGamesPerRound: ' . $numGamesPerRound);

    // Make sure the number of rounds is valid.
    if ($numRounds < 1 || $numRounds > 5) {
      error_log('Invalid number of rounds: ' . $numRounds);
      return '';
    }

    // Make sure the number of games per round is valid.
    if ($numGamesPerRound < 1 || $numGamesPerRound > 5) {
      error_log('Invalid number of games per round: ' . $numGamesPerRound);
      return '';
    }

    // First, look up the opponent.
    $stmt = $inPDO->prepare('SELECT username FROM users WHERE username=:username');
    $stmt->execute([':username'=>$opponentUsername]);
    $row = $stmt->fetch();
    $stmt->closeCursor();
    $stmt = null;

    if (empty($row)) {

      // Unknown opponent.
      error_log('Unknown opponent: ' . $opponentUsername);
      return '1';

    } else {

      // Ok, opponent is known, so now create the match record.
      $matchToken = bin2hex(openssl_random_pseudo_bytes(6));
      $stmt = $inPDO->prepare(
        'INSERT INTO matches (match_token, initiator_username, opponent_username, created, num_rounds, ' .
        'num_games_per_round, status, round_number, turn_indicator, initiator_score_round_1, ' .
        'initiator_score_round_2, initiator_score_round_3, initiator_score_round_4, initiator_score_round_5, ' .
        'opponent_score_round_1, opponent_score_round_2, opponent_score_round_3, opponent_score_round_4, ' .
        'opponent_score_round_5 ) VALUES (:match_token, :initiator_username, :opponent_username, NOW(), ' .
        ':num_rounds, :num_games_per_round, "p", 1, "o", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)'
      );
      $stmt->execute([
        ':match_token' => $matchToken,
        ':initiator_username' => $inUsername,
        ':opponent_username' => $opponentUsername,
        ':num_rounds' => $numRounds,
        ':num_games_per_round' => $numGamesPerRound
      ]);
      $stmt->closeCursor();
      $stmt = null;
      error_log('Invitation sent: ' . $matchToken);

      // Now get the match list.
      return getMatchStatus($inPDO, $inUsername);

    }

  } catch (Exception $inException) {
    error_log('EXCEPTION: sendInvitation(): ' . $inException->getMessage());
    return '';
  }

} /* End sendInvitation(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Accept Invitation.  Called to accept match invitation.  Also called to decline an invitation.
 *
 * POST body: '1a__________----------AAAAAAAAAAAAB'.
 *
 * Payload description:
 * AAAAAAAAAAAA .. Match token.
 * B ............. Acceptance (-a-ccept, -d-ecline).
 *
 * @param  pdo    $inPDO      A PDO object to execute database queries against.
 * @param  string $inUsername The username passed in, if any (not the one in the payload, if any).
 * @param  string $inPayload  Payload from the POST body.
 * @return string             0 = Accepted
 *                            Empty for any other invalid condition.
 */
function acceptInvitation($inPDO, $inUsername, $inPayload) {

  try {

    error_log('acceptInvitation()');

    // Validate payload length.
    $payloadLength = strlen($inPayload);
    if ($payloadLength != 13) {
      error_log('Payload incorrect length: ' . $payloadLength);
      return '';
    }

    // Pull data out of payload.
    $matchToken = substr($inPayload, 0, 12);
    $matchAcceptance = substr($inPayload, 12, 1);
    error_log('matchToken: ' . $matchToken);
    error_log('matchAcceptance: ' . $matchAcceptance);

    // Make sure the match acceptance code is a known code.
    if ($matchAcceptance != 'a' && $matchAcceptance != 'd') {
      error_log('Invalid acceptance code: ' . $matchAcceptance);
      return '';
    }

    // First, look up the match.
    $stmt = $inPDO->prepare(
      'SELECT match_token FROM matches WHERE match_token=:match_token AND opponent_username=:opponent_username'
    );
    $stmt->execute([':match_token'=>$matchToken, ':opponent_username'=>$inUsername]);
    $row = $stmt->fetch();
    $stmt->closeCursor();
    $stmt = null;

    if (empty($row)) {

      error_log('Match ' . $matchToken . ' not found');
      return '';

    } else {

      // An acceptance value of 'a' equates to a status of (r)unning (and in the case of a decline, the status
      // value doesn't really matter, so blank is good there).
      $matchStatus = '';
      if ($matchAcceptance === 'a') {
        $matchStatus = 'r';
      }
      $stmt = $inPDO->prepare(
        'UPDATE matches SET started=NOW(), last_update=NOW(), status=:status WHERE match_token=:match_token'
      );
      $stmt->execute([':match_token'=>$matchToken, ':status'=>$matchStatus]);
      $stmt->closeCursor();
      $stmt = null;
      error_log('Match ' . $matchToken . ' ' . $matchAcceptance);
      return '0';

    }

  } catch (Exception $inException) {
    error_log('EXCEPTION: acceptInvitation(): ' . $inException->getMessage());
    return '';
  }

} /* End acceptInvitation(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Get Match Statuses.  Called to get a list of matches the user is involved with in any capacity.  This takes care
 * of providing a list of matches the user has initiated, been invited to, or is currently playing.
 *
 * POST body: '1g__________----------'
 *
 * No payload.
 *
 *
 * @param  pdo    $inPDO      A PDO object to execute database queries against.
 * @param  string $inUsername The username passed in, if any (not the one in the payload, if any).
 * @return string             Returns a list of objects in the form
 *                              SSSSSSSSSSSSTTTTTTTTTTUUUUUUUUUUVWXYZOAAAABBBBCCCCCCCCCCCCCCC
 *                            where
 *                              SSSSSSSSSSSS ..... Match token.
 *                              TTTTTTTTTT ....... Initiator username.
 *                              UUUUUUUUUU ....... Opponent username.
 *                              V ................ Number of rounds.
 *                              W ................ Number of games per round.
 *                              X ................ Current status (-p-ending, -d-eclined, -r-unning, -e-nded).
 *                              Y ................ Current round.
 *                              Z ................ Current round who's turn (-i-nitiator's turn, -o-pponent's turn).
 *                              O ................ Outcome if match ended (-i-nitiator won, -o-pponent won).
 *                              AAAA ............. Final initiator match score.
 *                              BBBB ............. Final opponent match score.
 *                              CCCCCCCCCC ....... List of games for the current round (2 characters each, with the
 *                                                   entire string right-padded with spaces if less than 5 games).
 */
function getMatchStatus($inPDO, $inUsername) {

  try {

    error_log('getMatchStatus()');

    $matches = [ ];
    $stmt = $inPDO->prepare(
      'SELECT match_token, initiator_username, opponent_username, num_rounds, num_games_per_round, status, ' .
      'round_number, turn_indicator, outcome, games_round_1, games_round_2, games_round_3, games_round_4, ' .
      'initiator_score_round_1, initiator_score_round_2, initiator_score_round_3, initiator_score_round_4, ' .
      'initiator_score_round_5, opponent_score_round_1, opponent_score_round_2, opponent_score_round_3, ' .
      'opponent_score_round_4, opponent_score_round_5, games_round_5 FROM matches WHERE ' .
      'initiator_username=:initiator_username OR opponent_username=:opponent_username ORDER BY created DESC'
    );
    $stmt->execute([':initiator_username'=>$inUsername, ':opponent_username'=>$inUsername]);

    // Get the first row, if any.
    $row = $stmt->fetch();

    while ($row) {

      // Get initiator and opponent usernames and pad them out to the proper length.
      $initiatorUsername = str_pad($row['initiator_username'], 10, ' ');
      $opponentUsername = str_pad($row['opponent_username'], 10, ' ');

      // If the match hasn't ended yet we need to put a blank in the status area.
      $matchOutcome = $row['outcome'];
      if (empty($matchOutcome)) {
        $matchOutcome = ' ';
      }

      // Return all blanks for final scores, or calculate final scores if the match has ended.
      $initiatorFinalScore = '    ';
      $opponentFinalScore = '    ';
      if ($row['status'] === 'e') {
        $initiatorScoreRound1 = $row['initiator_score_round_1'];
        $initiatorScoreRound2 = $row['initiator_score_round_2'];
        $initiatorScoreRound3 = $row['initiator_score_round_3'];
        $initiatorScoreRound4 = $row['initiator_score_round_4'];
        $initiatorScoreRound5 = $row['initiator_score_round_5'];
        $initiatorFinalScore = $initiatorScoreRound1 + $initiatorScoreRound2 + $initiatorScoreRound3 +
          $initiatorScoreRound4 + $initiatorScoreRound5;
        $opponentScoreRound1 = $row['opponent_score_round_1'];
        $opponentScoreRound2 = $row['opponent_score_round_2'];
        $opponentScoreRound3 = $row['opponent_score_round_3'];
        $opponentScoreRound4 = $row['opponent_score_round_4'];
        $opponentScoreRound5 = $row['opponent_score_round_5'];
        $opponentFinalScore = $opponentScoreRound1 + $opponentScoreRound2 + $opponentScoreRound3 +
          $opponentScoreRound4 + $opponentScoreRound5;
        $initiatorFinalScore = str_pad($initiatorFinalScore, 4, ' ');
        $opponentFinalScore = str_pad($opponentFinalScore, 4, ' ');
      }

      // Return the list of games for the current round if it's the initiator's turn.
      $matchGames = '          ';
      if ($row['turn_indicator'] === 'i') {
        $matchGames = str_pad($row['games_round_' . $row['round_number']], 10, ' ');
      }

      // Build the final descriptor for this match and add to array to return.
      $strMatchData = $row['match_token'] . $initiatorUsername . $opponentUsername .
        $row['num_rounds'] . $row['num_games_per_round'] . $row['status'] . $row['round_number'] .
        $row['turn_indicator'] . $matchOutcome . $initiatorFinalScore . $opponentFinalScore . $matchGames;
      array_push($matches, $strMatchData);

      // Get the next row, if any.
      $row = $stmt->fetch();

    }

    $stmt->closeCursor();
    $stmt = null;

    if (count($matches) == 0) {
      return '~';
    }
    return join('~', $matches);

  } catch (Exception $inException) {
    error_log('EXCEPTION: getMatchStatus(): ' . $inException->getMessage());
    return '';
  }

} /* End getMatchStatus(). */


// ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------


/**
 * Update Match Status.  Called when the current player's turn ends.
 *
 * POST body: '1u__________----------AAAAAAAAAAAABBBBCCCCCCCCCC'.
 *
 * Payload description:
 * AAAAAAAAAAAA ..... Match token.
 * BBBB ............. Total score this round (right-padded with spaces).
 * CCCCCCCCCC ....... Game match IDs for up to 5 games (2 characters each, with the entire string right-padded with
 *                    spaces if less than 5 games).  Note that this is blank if this is the initiator's turn as it's
 *                    the opponent who 'chooses' the games for a given round.
 *
 * @param  pdo    $inPDO      A PDO object to execute database queries against.
 * @param  string $inUsername The username passed in, if any (not the one in the payload, if any).
 * @param  string $inPayload  Payload from the POST body.
 * @return string             0 = Successful update.
 *                            i = Initiator won the game.
 *                            o = Opponent won the game.
 *                            t = Game ends in a tie.
 *                            Empty string for any other invalid condition.
 */
function updateMatchStatus($inPDO, $inUsername, $inPayload) {

  try {

    error_log('updateMatchStatus()');

    // Validate payload length.
    $payloadLength = strlen($inPayload);
    if ($payloadLength != 26) {
      error_log('Payload incorrect length: ' . $payloadLength);
      return '';
    }

    // Pull data of payload.
    $matchToken = trim(substr($inPayload, 0, 12));
    $roundScore = intval(trim(substr($inPayload, 12, 4)));
    $roundGamesString = trim(substr($inPayload, 16));
    error_log('matchToken: ' . $matchToken);
    error_log('roundScore: ' . $roundScore);
    error_log('roundGamesString: ' . $roundGamesString);
    $roundGames = [ ];
    for ($i = 0; $i <= strlen($roundGamesString); $i = $i + 2) {
      array_push($roundGames, substr($roundGamesString, $i, 2));
    }

    // Retrieve data about the match.
    $stmt = $inPDO->prepare('SELECT * FROM matches WHERE match_token=:match_token');
    $stmt->execute([':match_token'=>$matchToken]);
    $row = $stmt->fetch();
    $stmt->closeCursor();
    $stmt = null;

    // We use turn_indicator a lot, and mutate it, so let's pull it out.
    $turnIndicator = $row['turn_indicator'];

    // Step 1: Was the match found?
    if (empty($row)) {

      error_log('Match ' . $matchToken . ' not found');
      return '';

    // Step 2: Is the match running?
    } else {

      if ($row['status'] !== 'r'/* and $skipChecks === false*/) {

        // Match not running.
        error_log('Match ' . $matchToken . ' not running');
        return '';

      // Step 3: Is it this player's turn?
      } else {

        // Figure out the username of the player who's turn it is.
        $turnPlayerUsername = trim($row['initiator_username']);
        if ($turnIndicator === 'o') {
          $turnPlayerUsername = trim($row['opponent_username']);
        }

        if ($inUsername !== $turnPlayerUsername/* and $skipChecks === false*/) {

          // Not this player's turn.
          error_log('Not this players turn: ' . $turnPlayerUsername);
          return '';

        // Step 4: End the match or flip to the other player's turn as appropriate.
        } else {

          // Figure out if this player is the initiator or opponent.
          $player = 'initiator';
          if ($inUsername === trim($row['opponent_username'])) {
            $player = 'opponent';
          }

          // If the list of games for this round is empty then that means this is the opponent's turn, so we need to
          // store the list of games sent in.
          $roundGamesToUpdate = $roundGamesString;
          if (empty($roundGamesString)) {
            $roundGamesToUpdate = $row['games_round_' . $row['round_number']];
          }

          // Update scores and games for the current round.
          $stmt = $inPDO->prepare(
            'UPDATE matches SET last_update=NOW(), ' .
            $player . '_score_round_' . $row['round_number'] . '=:round_score, ' .
            'games_round_' . $row['round_number'] . '=:round_games ' .
            'WHERE match_token=:match_token'
          );
          $stmt->execute([
            ':round_score'=>$roundScore, ':round_games'=>$roundGamesToUpdate, ':match_token'=>$matchToken
          ]);
          $stmt->closeCursor();
          $stmt = null;

          // Is it time to determine a winner?
          if ($row['round_number'] === $row['num_rounds'] && $turnIndicator === 'i') {

            // This is the last half of the last round, so end the match.  To do so, we need to figure out who won.
            // So, total all the scores, and be sure to add in the score for this round since it won't be present in
            // the row map we have at this point.
            $initiatorScoreRound1 = $row['initiator_score_round_1'];
            $initiatorScoreRound2 = $row['initiator_score_round_2'];
            $initiatorScoreRound3 = $row['initiator_score_round_3'];
            $initiatorScoreRound4 = $row['initiator_score_round_4'];
            $initiatorScoreRound5 = $row['initiator_score_round_5'];
            $initiatorTotalScore = $initiatorScoreRound1 + $initiatorScoreRound2 + $initiatorScoreRound3 +
              $initiatorScoreRound4 + $initiatorScoreRound5 + $roundScore;
            $opponentScoreRound1 = $row['opponent_score_round_1'];
            $opponentScoreRound2 = $row['opponent_score_round_2'];
            $opponentScoreRound3 = $row['opponent_score_round_3'];
            $opponentScoreRound4 = $row['opponent_score_round_4'];
            $opponentScoreRound5 = $row['opponent_score_round_5'];
            $opponentTotalScore = $opponentScoreRound1 + $opponentScoreRound2 + $opponentScoreRound3 +
              $opponentScoreRound4 + $opponentScoreRound5;

            // Now just a simple comparison.
            $gameOutcome = 't';
            if ($opponentTotalScore > $initiatorTotalScore) {
              $gameOutcome = 'o';
            } else if ($initiatorTotalScore > $opponentTotalScore) {
              $gameOutcome = 'i';
            }

            // And of course, write the outcome to the database.
            $stmt = $inPDO->prepare(
              'UPDATE matches SET last_update=NOW(), ended=NOW(), status="e", outcome=:game_outcome ' .
              'WHERE match_token=:match_token'
            );
            $stmt->execute([':game_outcome'=>$gameOutcome, ':match_token'=>$matchToken]);
            $stmt->closeCursor();
            $stmt = null;

            error_log('Game outcome: ' . $gameOutcome);
            return $gameOutcome;

          } else {

            // The match isn't over, so flip the turn indicator and bump the round number if necessary.
            $roundNumber = $row['round_number'];
            if ($turnIndicator === 'i') {
              $turnIndicator = 'o';
              $roundNumber = $roundNumber + 1;
            } else {
              $turnIndicator = 'i';
            }
            $stmt = $inPDO->prepare(
              'UPDATE matches SET last_update=NOW(), turn_indicator=:turn_indicator, round_number=:round_number ' .
              'WHERE match_token=:match_token'
            );
            $stmt->execute([
              ':turn_indicator'=>$turnIndicator, ':round_number'=>$roundNumber, ':match_token'=>$matchToken
            ]);
            $stmt->closeCursor();
            $stmt = null;

            error_log('Match ' . $matchToken . ' updated');
            return '0';

          } /* End step 4. */

        } /* End step 3. */

      } /* End step 2. */

    } /* End step 1. */

  } catch (Exception $inException) {
    error_log('EXCEPTION: updateMatchStatus(): ' . $inException->getMessage());
    return '';
  }

} /* End updateMatchStatus(). */
