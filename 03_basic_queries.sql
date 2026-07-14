-- ============================================================
-- LEVEL 1: BASIC  (SELECT, WHERE, ORDER BY, LIKE, aggregates)
-- ============================================================

-- B1. List all teams alphabetically
SELECT team_name, confederation, fifa_ranking
FROM Teams
ORDER BY team_name;

+-----------+---------------+--------------+
| team_name | confederation | fifa_ranking |
+-----------+---------------+--------------+
| Argentina | CONMEBOL      |            1 |
| Brazil    | CONMEBOL      |            3 |
| England   | UEFA          |            4 |
| France    | UEFA          |            2 |
| Germany   | UEFA          |            6 |
| Japan     | AFC           |            8 |
| Morocco   | CAF           |            7 |
| Spain     | UEFA          |            5 |
+-----------+---------------+--------------+

-- B2. List all players belonging to Argentina
SELECT player_name, jersey_number, position
FROM Players
WHERE team_id = (SELECT team_id FROM Teams WHERE team_name = 'Argentina');

+-------------------+---------------+------------+
| player_name       | jersey_number | position   |
+-------------------+---------------+------------+
| Rodrigo De Paul   |             7 | Midfielder |
| Lionel Messi      |            10 | Forward    |
| Emiliano Martinez |            23 | Goalkeeper |
+-------------------+---------------+------------+

-- B3. List all matches ordered by date (earliest first)
SELECT match_id, stage, match_date, team1_score, team2_score
FROM Matches
ORDER BY match_date ASC;
+----------+---------------+---------------------+-------------+-------------+
| match_id | stage         | match_date          | team1_score | team2_score |
+----------+---------------+---------------------+-------------+-------------+
|        1 | Group Stage   | 2026-06-14 16:00:00 |           2 |           1 |
|        2 | Group Stage   | 2026-06-14 19:00:00 |           1 |           1 |
|        3 | Group Stage   | 2026-06-15 16:00:00 |           3 |           1 |
|        4 | Group Stage   | 2026-06-15 19:00:00 |           0 |           0 |
|        5 | Group Stage   | 2026-06-19 16:00:00 |           2 |           2 |
|        6 | Group Stage   | 2026-06-19 19:00:00 |           1 |           0 |
|        7 | Quarter Final | 2026-06-25 18:00:00 |           0 |           0 |
+----------+---------------+---------------------+-------------+-------------+


-- B4. Find all teams from the UEFA confederation
SELECT team_name, fifa_ranking
FROM Teams
WHERE confederation = 'UEFA';
    -> WHERE confederation = 'UEFA';
+-----------+--------------+
| team_name | fifa_ranking |
+-----------+--------------+
| France    |            2 |
| England   |            4 |
| Spain     |            5 |
| Germany   |            6 |
+-----------+--------------+

-- B5. List stadiums with a capacity greater than 50,000
SELECT stadium_name, city, capacity
FROM Stadiums
WHERE capacity > 50000
ORDER BY capacity DESC;
    -> ORDER BY capacity DESC;
+-----------------+---------+----------+
| stadium_name    | city    | capacity |
+-----------------+---------+----------+
| Lusail Stadium  | Lusail  |    88966 |
| Al Bayt Stadium | Al Khor |    60000 |
+-----------------+---------+----------+

-- B6. Count the total number of teams in the tournament
SELECT COUNT(*) AS total_teams
FROM Teams;
+-------------+
| total_teams |
+-------------+
|           8 |
+-------------+
-- B7. Find players whose name starts with the letter 'M'
SELECT player_name, position
FROM Players
WHERE player_name LIKE 'M%';
    -> WHERE player_name LIKE 'M%';
+--------------+------------+
| player_name  | position   |
+--------------+------------+
| Manuel Neuer | Goalkeeper |
+--------------+------------+

-- B8. List all distinct confederations represented
SELECT DISTINCT confederation
FROM Teams;
+---------------+
| confederation |
+---------------+
| CONMEBOL      |
| UEFA          |
| CAF           |
| AFC           |
+---------------+

-- B9. List all matches that have been completed
SELECT match_id, stage, match_date
FROM Matches
WHERE status = 'Completed';
+----------+-------------+---------------------+
| match_id | stage       | match_date          |
+----------+-------------+---------------------+
|        1 | Group Stage | 2026-06-14 16:00:00 |
|        2 | Group Stage | 2026-06-14 19:00:00 |
|        3 | Group Stage | 2026-06-15 16:00:00 |
|        4 | Group Stage | 2026-06-15 19:00:00 |
|        5 | Group Stage | 2026-06-19 16:00:00 |
|        6 | Group Stage | 2026-06-19 19:00:00 |
+----------+-------------+---------------------+

-- B10. Find all referees from Spain
SELECT referee_name, country
FROM Referees
WHERE country = 'Spain';
+---------------------+---------+
| referee_name        | country |
+---------------------+---------+
| Antonio Mateu Lahoz | Spain   |
+---------------------+---------+
