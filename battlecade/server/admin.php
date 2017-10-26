<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'admin.log');

// Avoid locale warnings.
date_default_timezone_set('America/New_York');

// Our database connection.
$pdo = null;

// Our password.
$validPW = 'XXX';

try {

  error_log('Admin invoked');

  $pw = $_GET['pw'];

  if ($pw == $validPW) {

    error_log('Password validated');

    // Server response message, if any.
    $serverMsg = '';

    // Get ready for database work.
    $pdo = new PDO('mysql:host=localhost;dbname=XXX', 'XXX', 'XXX');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Default display style for the two lists.
    $userListDisplay = 'none';
    $matchListDisplay = 'none';

    // See if there's a function we need to execute.
    $fn = isset($_GET['fn']) ? $_GET['fn'] : '';
    error_log('fn = ' . $fn);

    // Delete user.
    if ($fn == 'du') {
      error_log('Delete user: ' . $_GET['un']);
      $stmt = $pdo->prepare('DELETE FROM users WHERE username="' . $_GET['un'] . '"');
      $stmt->execute();
      $userListDisplay = '';
      $serverMsg = 'User ' . $_GET['un'] . ' deleted';
    }

    // Update user.
    if ($fn == 'uu') {
      error_log('Uodate user: ' . $_GET['un'] . ' (password=' . $_GET['pw'] . ')');
      $stmt = $pdo->prepare('UPDATE users SET password="' . $_GET['pw'] . '" WHERE username="' . $_GET['un'] . '"');
      $stmt->execute();
      $userListDisplay = '';
      $serverMsg = 'User ' . $_GET['un'] . ' updated';
    }

    // Delete match.
    if ($fn == 'dm') {
      error_log('Delete match: ' . $_GET['mt']);
      $stmt = $pdo->prepare('DELETE FROM matches WHERE match_token="' . $_GET['mt'] . '"');
      $stmt->execute();
      $matchListDisplay = '';
      $serverMsg = 'Match ' . $_GET['mt'] . ' deleted';
    }

    // Get list of users.
    error_log('Getting list of users');
    $userList = [ ];
    $stmt = $pdo->prepare('SELECT * FROM users ORDER BY username ASC');
    $stmt->execute();
    $row = $stmt->fetch();
    while ($row) {
      $strUser =
        '<tr>' .
          '<td>' .
            '<input type="button" value="Delete" onClick="deleteUser(\'' . $row['username'] . '\');">&nbsp;' .
            '<input type="button" value="Update" onClick="updateUser(\'' . $row['username'] . '\');">' .
          '</td>' .
          '<td>' . $row['username'] . '</td>' .
          '<td>' .
            '<input type="text" id="user_password_' . $row['username'] .
            '" value="' . $row['password'] . '" maxlength="10" size="12" />' .
          '</td>' .
          '<td>' . date('m/d/Y', strtotime($row['last_contact'])) . '</td>' .
        '</tr>';
      array_push($userList, $strUser);
      $row = $stmt->fetch();
    }

    // Get list of matches.
    error_log('Getting list of matches');
    $matchList = [ ];
    $stmt = $pdo->prepare('SELECT * FROM matches ORDER BY match_token ASC');
    $stmt->execute();
    $row = $stmt->fetch();
    while($row) {
      $strMatch =
        '<tr>' .
          '<td>' .
            '<input type="button" value="Delete" onClick="deleteMatch(\'' . $row['match_token'] . '\');">' .
          '</td>' .
          '<td>' . $row['match_token'] . '</td>' .
          '<td>' . $row['initiator_username'] . '</td>' .
          '<td>' . $row['opponent_username'] . '</td>' .
          '<td>' . date('m/d/Y', strtotime($row['created'])) . '</td>' .
          '<td>' . date('m/d/Y', strtotime($row['started'])) . '</td>' .
          '<td>' . date('m/d/Y', strtotime($row['last_update'])) . '</td>' .
          '<td>' . date('m/d/Y', strtotime($row['ended'])) . '</td>' .
          '<td>' . $row['num_rounds'] . '</td>' .
          '<td>' . $row['num_games_per_round'] . '</td>' .
          '<td>' . $row['status'] . '</td>' .
          '<td>' . $row['round_number'] . '</td>' .
          '<td>' . $row['turn_indicator'] . '</td>' .
          '<td>' . $row['outcome'] . '</td>' .
          '<td>' . $row['initiator_score_round_1'] . '</td>' .
          '<td>' . $row['initiator_score_round_2'] . '</td>' .
          '<td>' . $row['initiator_score_round_3'] . '</td>' .
          '<td>' . $row['initiator_score_round_4'] . '</td>' .
          '<td>' . $row['initiator_score_round_5'] . '</td>' .
          '<td>' . $row['opponent_score_round_1'] . '</td>' .
          '<td>' . $row['opponent_score_round_2'] . '</td>' .
          '<td>' . $row['opponent_score_round_3'] . '</td>' .
          '<td>' . $row['opponent_score_round_4'] . '</td>' .
          '<td>' . $row['opponent_score_round_5'] . '</td>' .
          '<td>' . $row['games_round_1'] . '</td>' .
          '<td>' . $row['games_round_2'] . '</td>' .
          '<td>' . $row['games_round_3'] . '</td>' .
          '<td>' . $row['games_round_4'] . '</td>' .
          '<td>' . $row['games_round_5'] . '</td>' .
        '</tr>';
      array_push($matchList, $strMatch);
      $row = $stmt->fetch();
    }

// --------------------------------------------------------------------------------------------------------------------
?>





<!DOCTYPE html>
<html><head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>MCC-A</title>
  <style>
    th {
      background-color: #e0e0e0;
      padding-right: 10px;
    }
  </style>
  <script>

    var pw = "<?php echo($validPW); ?>";

    function listUsers() {
      document.getElementById("divListUsers").style.display = "";
      document.getElementById("divListMatches").style.display = "none";
    }

    function listMatches() {
      document.getElementById("divListUsers").style.display = "none";
      document.getElementById("divListMatches").style.display = "";
    }

    function deleteUser(inUsername) {
      if (confirm("Are you sure you want to delete user '" + inUsername + "'?")) {
        window.location = "__admin.php?pw=" + pw + "&fn=du&un=" + inUsername;
      }
    }

    function updateUser(inUsername) {
      if (confirm("Are you sure you want to update the password for user '" + inUsername + "'?")) {
        window.location = "__admin.php?pw=" + pw + "&fn=uu&un=" + inUsername + "&pw=" +
          document.getElementById("user_password_" + inUsername).value;
      }
    }

    function deleteMatch(inMatchToken) {
      if (confirm("Are you sure you want to delete match '" + inMatchToken + "'?")) {
        window.location = "__admin.php?pw=" + pw + "&fn=dm&mt=" + inMatchToken;
      }
    }

  </script>
</head><body>

  <input type="button" value="List Users" onClick="listUsers();">
  <input type="button" value="List Matches" onClick="listMatches();">
  <br><br>
  <div id="divMessage" style="color:#ff0000;font-weight:bold;"><?php echo $serverMsg; ?></div>
  <br><hr>

  <!-- List Users. -->
  <div id="divListUsers" style="display:<?php echo $userListDisplay;?>;width:99%;overflow:auto;">
    <h1>Users</h1>
    <table border="1" cellpadding="4" cellspacing="0">
      <tr>
        <th>&nbsp;</th><th>USERNAME</th><th>PASSWORD</th><th>LAST_CONTACT</th>
      </tr>
      <?php echo join('', $userList); ?>
    </table>
  </div>

  <!-- List Matches. -->
  <div id="divListMatches" style="display:<?php echo $matchListDisplay;?>;width:99%;overflow:auto;">
    <h1>Matches</h1>
    <table border="1" cellpadding="4" cellspacing="0">
      <tr>
        <th>&nbsp;</th><th>MATCH_TOKEN</th><th>INITIATOR_USERNAME</th><th>OPPONENT_USERNAME</th><th>CREATED</th>
        <th>STARTED</th><th>LAST_UPDATE</th><th>ENDED</th><th>NUM_ROUNDS</th><th>NUM_GAMES_PER_ROUND</th>
        <th>STATUS</th><th>ROUND_NUMBER</th><th>TURN_INDICATOR</th><th>OUTCOME</th><th>INITIATOR_SCORE_ROUND_1</th>
        <th>INITIATOR_SCORE_ROUND_2</th><th>INITIATOR_SCORE_ROUND_3</th><th>INITIATOR_SCORE_ROUND_4</th>
        <th>INITIATOR_SCORE_ROUND_5</th><th>OPPONENT_SCORE_ROUND_1</th><th>OPPONENT_SCORE_ROUND_2</th>
        <th>OPPONENT_SCORE_ROUND_3</th><th>OPPONENT_SCORE_ROUND_4</th><th>OPPONENT_SCORE_ROUND_5</th>
        <th>GAMES_ROUND_1</th><th>GAMES_ROUND_2</th><th>GAMES_ROUND_3</th><th>GAMES_ROUND_4</th><th>GAMES_ROUND_5</th>
      </tr>
      <?php echo join('', $matchList); ?>
    </table>
  </div>

</body></html>





<?php
// --------------------------------------------------------------------------------------------------------------------

  } else {
    error_log('Password NOT valid: ' . $pw);
  } /* End PW check. */

} catch (PDOException $inPDOException) {
  error_log(
    'Exception creating PDO object: ' . $inPDOException->getMessage() . ' (Code: ' . $inPDOException->getCode() . ')'
  );
} catch (Exception $inException) {
  error_log(
    'General exception: ' . $inException->getMessage() . ' (Code: ' . $inException->getCode() . ')'
  );
} finally {
  if (!empty($pdo)) {
    $pdo = null;
  }
}
