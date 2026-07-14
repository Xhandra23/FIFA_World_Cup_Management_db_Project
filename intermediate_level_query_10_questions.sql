-- ============================================================
-- LEVEL 2: INTERMEDIATE  (JOINs, GROUP BY, HAVING, subqueries)
-- ============================================================

-- I1. Count how many players each team has registered

SELECT t.team_name, COUNT(p.player_id) AS squad_size
FROM Teams t
LEFT JOIN Players p ON t.team_id = p.team_id
GROUP BY t.team_id, t.team_name
ORDER BY squad_size DESC;

+-----------+------------+
| team_name | squad_size |
+-----------+------------+
| Argentina |          3 |
| Brazil    |          3 |
| France    |          3 |
| England   |          2 |
| Germany   |          2 |
| Japan     |          2 |
| Morocco   |          2 |
| Spain     |          2 |
+-----------+------------+

-- I2. Total goals scored by each team

SELECT t.team_name, COUNT(g.goal_id) AS total_goals
FROM Teams t
LEFT JOIN Goals g ON t.team_id = g.team_id
GROUP BY t.team_id, t.team_name
ORDER BY total_goals DESC;

+-----------+-------------+
| team_name | total_goals |
+-----------+-------------+
| Argentina |           4 |
| France    |           4 |
| Brazil    |           3 |
| Germany   |           1 |
| Japan     |           1 |
| Morocco   |           1 |
| England   |           0 |
| Spain     |           0 |
+-----------+-------------+

-- I3. Show all matches with team names instead of IDs

SELECT m.match_id, t1.team_name AS home_team, m.team1_score,
       t2.team_name AS away_team, m.team2_score, m.stage
FROM Matches m
JOIN Teams t1 ON m.team1_id = t1.team_id
JOIN Teams t2 ON m.team2_id = t2.team_id;

+----------+-----------+-------------+-----------+-------------+---------------+
| match_id | home_team | team1_score | away_team | team2_score | stage         |
+----------+-----------+-------------+-----------+-------------+---------------+
|        1 | Argentina |           2 | Japan     |           1 | Group Stage   |
|        2 | Brazil    |           1 | Morocco   |           1 | Group Stage   |
|        3 | France    |           3 | Germany   |           1 | Group Stage   |
|        4 | England   |           0 | Spain     |           0 | Group Stage   |
|        5 | Argentina |           2 | Brazil    |           2 | Group Stage   |
|        6 | France    |           1 | England   |           0 | Group Stage   |
|        7 | Argentina |           0 | England   |           0 | Quarter Final |
+----------+-----------+-------------+-----------+-------------+---------------+

-- I4. Average FIFA ranking per confederation

SELECT confederation, ROUND(AVG(fifa_ranking), 1) AS avg_ranking
FROM Teams
GROUP BY confederation
ORDER BY avg_ranking;
+---------------+-------------+
| confederation | avg_ranking |
+---------------+-------------+
| CONMEBOL      |         2.0 |
| UEFA          |         4.3 |
| CAF           |         7.0 |
| AFC           |         8.0 |
+---------------+-------------+

-- I5. List players who have scored at least one goal

SELECT DISTINCT p.player_name, t.team_name
FROM Players p
JOIN Goals g ON p.player_id = g.player_id
JOIN Teams t ON p.team_id = t.team_id;
+-------------------+-----------+
| player_name       | team_name |
+-------------------+-----------+
| Lionel Messi      | Argentina |
| Rodrigo De Paul   | Argentina |
| Kylian Mbappe     | France    |
| Antoine Griezmann | France    |
| Neymar Jr         | Brazil    |
| Vinicius Junior   | Brazil    |
| Manuel Neuer      | Germany   |
| Yassine Bounou    | Morocco   |
| Shuichi Gonda     | Japan     |
+-------------------+-----------+

-- I6. Teams that have more than 2 registered players in the database

SELECT t.team_name, COUNT(p.player_id) AS squad_size
FROM Teams t
JOIN Players p ON t.team_id = p.team_id
GROUP BY t.team_id, t.team_name
HAVING COUNT(p.player_id) > 2;

+-----------+------------+
| team_name | squad_size |
+-----------+------------+
| Argentina |          3 |
| Brazil    |          3 |
| France    |          3 |
+-----------+------------+

-- I7. Find the match with the highest combined score (most entertaining match)

SELECT m.match_id, t1.team_name, m.team1_score, t2.team_name, m.team2_score,
       (m.team1_score + m.team2_score) AS total_goals
FROM Matches m
JOIN Teams t1 ON m.team1_id = t1.team_id
JOIN Teams t2 ON m.team2_id = t2.team_id
ORDER BY total_goals DESC
LIMIT 1;
+----------+-----------+-------------+-----------+-------------+-------------+
| match_id | team_name | team1_score | team_name | team2_score | total_goals |
+----------+-----------+-------------+-----------+-------------+-------------+
|        3 | France    |           3 | Germany   |           1 |           4 |
+----------+-----------+-------------+-----------+-------------+-------------+

-- I8. List all cards issued, with player name, team, and match stage

SELECT p.player_name, t.team_name, c.card_type, c.card_minute, m.stage
FROM Cards c
JOIN Players p ON c.player_id = p.player_id
JOIN Teams t ON p.team_id = t.team_id
JOIN Matches m ON c.match_id = m.match_id
ORDER BY c.card_type, c.card_minute;
+-----------------+-----------+-----------+-------------+-------------+
| player_name     | team_name | card_type | card_minute | stage       |
+-----------------+-----------+-----------+-------------+-------------+
| Manuel Neuer    | Germany   | Red       |          85 | Group Stage |
| Rodrigo De Paul | Argentina | Yellow    |          40 | Group Stage |
| Yassine Bounou  | Morocco   | Yellow    |          55 | Group Stage |
| Vinicius Junior | Brazil    | Yellow    |          66 | Group Stage |
+-----------------+-----------+-----------+-------------+-------------+

-- I9. Stadiums that have hosted more than 1 match

SELECT s.stadium_name, COUNT(m.match_id) AS matches_hosted
FROM Stadiums s
JOIN Matches m ON s.stadium_id = m.stadium_id
GROUP BY s.stadium_id, s.stadium_name
HAVING COUNT(m.match_id) > 1;
+------------------------+----------------+
| stadium_name           | matches_hosted |
+------------------------+----------------+
| Lusail Stadium         |              3 |
| Education City Stadium |              2 |
+------------------------+----------------+

-- I10. Find teams that have NOT yet played any match

SELECT team_name
FROM Teams
WHERE team_id NOT IN (
    SELECT team1_id FROM Matches
    UNION
    SELECT team2_id FROM Matches
);

Empty set
