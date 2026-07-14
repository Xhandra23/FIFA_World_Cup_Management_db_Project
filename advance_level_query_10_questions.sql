-- ============================================================
-- LEVEL 3: ADVANCED  (window functions, CTEs, self joins, correlated subqueries)
-- ============================================================

-- A1. Rank players by total goals within their own team (window function)

SELECT
    t.team_name,
    p.player_name,
    COUNT(g.goal_id) AS goals,
    RANK() OVER (PARTITION BY t.team_id ORDER BY COUNT(g.goal_id) DESC) AS team_rank
FROM Players p
JOIN Teams t ON p.team_id = t.team_id
LEFT JOIN Goals g ON p.player_id = g.player_id
GROUP BY t.team_id, t.team_name, p.player_id, p.player_name;
+-----------+-------------------+-------+-----------+
| team_name | player_name       | goals | team_rank |
+-----------+-------------------+-------+-----------+
| Argentina | Lionel Messi      |     3 |         1 |
| Argentina | Rodrigo De Paul   |     1 |         2 |
| Argentina | Emiliano Martinez |     0 |         3 |
| France    | Kylian Mbappe     |     3 |         1 |
| France    | Antoine Griezmann |     1 |         2 |
| France    | Hugo Lloris       |     0 |         3 |
| Brazil    | Neymar Jr         |     2 |         1 |
| Brazil    | Vinicius Junior   |     1 |         2 |
| Brazil    | Alisson Becker    |     0 |         3 |
| England   | Harry Kane        |     0 |         1 |
| England   | Jordan Pickford   |     0 |         1 |
| Spain     | Alvaro Morata     |     0 |         1 |
| Spain     | Unai Simon        |     0 |         1 |
| Germany   | Manuel Neuer      |     1 |         1 |
| Germany   | Ilkay Gundogan    |     0 |         2 |
| Morocco   | Yassine Bounou    |     1 |         1 |
| Morocco   | Achraf Hakimi     |     0 |         2 |
| Japan     | Shuichi Gonda     |     1 |         1 |
| Japan     | Takefusa Kubo     |     0 |         2 |
+-----------+-------------------+-------+-----------+

-- A2. Running total of goals scored by each team, ordered by match date
WITH team_goals_by_match AS (
    SELECT g.team_id, m.match_date, COUNT(g.goal_id) AS goals_in_match
    FROM Goals g
    JOIN Matches m ON g.match_id = m.match_id
    GROUP BY g.team_id, m.match_id, m.match_date
)
SELECT
    t.team_name,
    tgm.match_date,
    tgm.goals_in_match,
    SUM(tgm.goals_in_match) OVER (PARTITION BY tgm.team_id ORDER BY tgm.match_date) AS running_total
FROM team_goals_by_match tgm
JOIN Teams t ON tgm.team_id = t.team_id
ORDER BY t.team_name, tgm.match_date;


+-----------+---------------------+----------------+---------------+
| team_name | match_date          | goals_in_match | running_total |
+-----------+---------------------+----------------+---------------+
| Argentina | 2026-06-14 16:00:00 |              2 |             2 |
| Argentina | 2026-06-19 16:00:00 |              2 |             4 |
| Brazil    | 2026-06-14 19:00:00 |              1 |             1 |
| Brazil    | 2026-06-19 16:00:00 |              2 |             3 |
| France    | 2026-06-15 16:00:00 |              3 |             3 |
| France    | 2026-06-19 19:00:00 |              1 |             4 |
| Germany   | 2026-06-15 16:00:00 |              1 |             1 |
| Japan     | 2026-06-14 16:00:00 |              1 |             1 |
| Morocco   | 2026-06-14 19:00:00 |              1 |             1 |
+-----------+---------------------+----------------+---------------+

-- A3. Top scorer in each group (CTE + window function)

WITH group_scorers AS (
    SELECT
        tg.group_name,
        p.player_name,
        t.team_name,
        COUNT(g.goal_id) AS goals,
        RANK() OVER (PARTITION BY tg.group_name ORDER BY COUNT(g.goal_id) DESC) AS rnk
    FROM Goals g
    JOIN Players p ON g.player_id = p.player_id
    JOIN Teams t ON g.team_id = t.team_id
    JOIN Group_Teams gt ON t.team_id = gt.team_id
    JOIN Tournament_Groups tg ON gt.group_id = tg.group_id
    GROUP BY tg.group_name, p.player_id, p.player_name, t.team_name
)
SELECT group_name, player_name, team_name, goals
FROM group_scorers
WHERE rnk = 1;

+------------+---------------+-----------+-------+
| group_name | player_name   | team_name | goals |
+------------+---------------+-----------+-------+
| A          | Lionel Messi  | Argentina |     3 |
| B          | Kylian Mbappe | France    |     3 |
+------------+---------------+-----------+-------+

-- A4. Head-to-head results using a self join on Matches (all pairings played twice or more)

SELECT
    t1.team_name AS team_a,
    t2.team_name AS team_b,
    COUNT(*) AS times_played
FROM Matches m1
JOIN Matches m2
    ON (m1.team1_id = m2.team2_id AND m1.team2_id = m2.team1_id)
    AND m1.match_id < m2.match_id
JOIN Teams t1 ON m1.team1_id = t1.team_id
JOIN Teams t2 ON m1.team2_id = t2.team_id
GROUP BY t1.team_name, t2.team_name;

-- A5. Overall Golden Boot leaderboard with DENSE_RANK (ties share the same rank)
SELECT
    p.player_name,
    t.team_name,
    COUNT(g.goal_id) AS goals,
    DENSE_RANK() OVER (ORDER BY COUNT(g.goal_id) DESC) AS golden_boot_rank
FROM Goals g
JOIN Players p ON g.player_id = p.player_id
JOIN Teams t ON g.team_id = t.team_id
GROUP BY p.player_id, p.player_name, t.team_name;

+-------------------+-----------+-------+------------------+
| player_name       | team_name | goals | golden_boot_rank |
+-------------------+-----------+-------+------------------+
| Lionel Messi      | Argentina |     3 |                1 |
| Kylian Mbappe     | France    |     3 |                1 |
| Neymar Jr         | Brazil    |     2 |                2 |
| Rodrigo De Paul   | Argentina |     1 |                3 |
| Antoine Griezmann | France    |     1 |                3 |
| Vinicius Junior   | Brazil    |     1 |                3 |
| Manuel Neuer      | Germany   |     1 |                3 |
| Yassine Bounou    | Morocco   |     1 |                3 |
| Shuichi Gonda     | Japan     |     1 |                3 |
+-------------------+-----------+-------+------------------+

-- A6. Full group standings table computed with points, GD and a final rank column


WITH match_results AS (
    SELECT m.group_id, m.team1_id AS team_id, m.team1_score AS gf, m.team2_score AS ga,
           CASE WHEN m.team1_score > m.team2_score THEN 'W'
                WHEN m.team1_score = m.team2_score THEN 'D' ELSE 'L' END AS result
    FROM Matches m WHERE m.status = 'Completed' AND m.stage = 'Group Stage'
    UNION ALL
    SELECT m.group_id, m.team2_id AS team_id, m.team2_score AS gf, m.team1_score AS ga,
           CASE WHEN m.team2_score > m.team1_score THEN 'W'
                WHEN m.team2_score = m.team1_score THEN 'D' ELSE 'L' END AS result
    FROM Matches m WHERE m.status = 'Completed' AND m.stage = 'Group Stage'
),
standings AS (
    SELECT
        tg.group_name, t.team_name,
        SUM(mr.gf) - SUM(mr.ga) AS gd,
        SUM(mr.result = 'W') * 3 + SUM(mr.result = 'D') AS points
    FROM match_results mr
    JOIN Teams t ON mr.team_id = t.team_id
    JOIN Tournament_Groups tg ON mr.group_id = tg.group_id
    GROUP BY tg.group_name, t.team_id, t.team_name
)
SELECT
    group_name, team_name, points, gd,
    RANK() OVER (PARTITION BY group_name ORDER BY points DESC, gd DESC) AS position
FROM standings
ORDER BY group_name, position;

+------------+-----------+--------+------+----------+
| group_name | team_name | points | gd   | position |
+------------+-----------+--------+------+----------+
| A          | Argentina |      4 |    1 |        1 |
| A          | Brazil    |      2 |    0 |        2 |
| A          | Morocco   |      1 |    0 |        3 |
| A          | Japan     |      0 |   -1 |        4 |
| B          | France    |      6 |    3 |        1 |
| B          | Spain     |      1 |    0 |        2 |
| B          | England   |      1 |   -1 |        3 |
| B          | Germany   |      0 |   -2 |        4 |
+------------+-----------+--------+------+----------+

-- A7. Matches where the winning team scored more goals than the tournament's average goals-per-team-per-match

SELECT m.match_id, t1.team_name, m.team1_score, t2.team_name, m.team2_score
FROM Matches m
JOIN Teams t1 ON m.team1_id = t1.team_id
JOIN Teams t2 ON m.team2_id = t2.team_id
WHERE GREATEST(m.team1_score, m.team2_score) > (
    SELECT AVG(goals) FROM (
        SELECT team1_score AS goals FROM Matches WHERE status = 'Completed'
        UNION ALL
        SELECT team2_score AS goals FROM Matches WHERE status = 'Completed'
    ) AS all_scores
);

+----------+-----------+-------------+-----------+-------------+
| match_id | team_name | team1_score | team_name | team2_score |
+----------+-----------+-------------+-----------+-------------+
|        1 | Argentina |           2 | Japan     |           1 |
|        3 | France    |           3 | Germany   |           1 |
|        5 | Argentina |           2 | Brazil    |           2 |
+----------+-----------+-------------+-----------+-------------+

-- A8. Goal-difference ranking across ALL teams (not just group stage), using a window function
SELECT
    t.team_name,
    SUM(CASE WHEN m.team1_id = t.team_id THEN m.team1_score ELSE m.team2_score END) AS goals_for,
    SUM(CASE WHEN m.team1_id = t.team_id THEN m.team2_score ELSE m.team1_score END) AS goals_against,
    SUM(CASE WHEN m.team1_id = t.team_id THEN m.team1_score ELSE m.team2_score END)
      - SUM(CASE WHEN m.team1_id = t.team_id THEN m.team2_score ELSE m.team1_score END) AS goal_diff,
    RANK() OVER (ORDER BY
        SUM(CASE WHEN m.team1_id = t.team_id THEN m.team1_score ELSE m.team2_score END)
      - SUM(CASE WHEN m.team1_id = t.team_id THEN m.team2_score ELSE m.team1_score END) DESC
    ) AS gd_rank
FROM Teams t
JOIN Matches m ON t.team_id IN (m.team1_id, m.team2_id) AND m.status = 'Completed'
GROUP BY t.team_id, t.team_name;

+-----------+-----------+---------------+-----------+---------+
| team_name | goals_for | goals_against | goal_diff | gd_rank |
+-----------+-----------+---------------+-----------+---------+
| France    |         4 |             1 |         3 |       1 |
| Argentina |         4 |             3 |         1 |       2 |
| Brazil    |         3 |             3 |         0 |       3 |
| Morocco   |         1 |             1 |         0 |       3 |
| Spain     |         0 |             0 |         0 |       3 |
| Japan     |         1 |             2 |        -1 |       6 |
| England   |         0 |             1 |        -1 |       6 |
| Germany   |         1 |             3 |        -2 |       8 |
+-----------+-----------+---------------+-----------+---------+
-- A9. Each team's top individual performer (goals + 0.5 x cards as a simple "involvement" score)
WITH player_scores AS (
    SELECT
        p.player_id, p.player_name, p.team_id,
        COUNT(DISTINCT g.goal_id) AS goals,
        COUNT(DISTINCT c.card_id) AS cards,
        COUNT(DISTINCT g.goal_id) + 0.5 * COUNT(DISTINCT c.card_id) AS involvement_score
    FROM Players p
    LEFT JOIN Goals g ON p.player_id = g.player_id
    LEFT JOIN Cards c ON p.player_id = c.player_id
    GROUP BY p.player_id, p.player_name, p.team_id
)
SELECT team_name, player_name, goals, cards, involvement_score
FROM (
    SELECT t.team_name, ps.player_name, ps.goals, ps.cards, ps.involvement_score,
           ROW_NUMBER() OVER (PARTITION BY ps.team_id ORDER BY ps.involvement_score DESC) AS rn
    FROM player_scores ps
    JOIN Teams t ON ps.team_id = t.team_id
) ranked
WHERE rn = 1 AND involvement_score > 0;

+-----------+----------------+-------+-------+-------------------+
| team_name | player_name    | goals | cards | involvement_score |
+-----------+----------------+-------+-------+-------------------+
| Argentina | Lionel Messi   |     3 |     0 |               3.0 |
| France    | Kylian Mbappe  |     3 |     0 |               3.0 |
| Brazil    | Neymar Jr      |     2 |     0 |               2.0 |
| Germany   | Manuel Neuer   |     1 |     1 |               1.5 |
| Morocco   | Yassine Bounou |     1 |     1 |               1.5 |
| Japan     | Shuichi Gonda  |     1 |     0 |               1.0 |
+-----------+----------------+-------+-------+-------------------+

-- A10. Teams that have both won at least one match AND lost at least one match (conditional aggregation)
SELECT t.team_name
FROM Teams t
JOIN (
    SELECT team1_id AS team_id, team1_score AS gf, team2_score AS ga FROM Matches WHERE status = 'Completed'
    UNION ALL
    SELECT team2_id AS team_id, team2_score AS gf, team1_score AS ga FROM Matches WHERE status = 'Completed'
) results ON t.team_id = results.team_id
GROUP BY t.team_id, t.team_name
HAVING SUM(gf > ga) > 0 AND SUM(gf < ga) > 0;

Empty set
