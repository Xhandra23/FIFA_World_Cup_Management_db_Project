CREATE DATABASE fifa_world_cup;
USE fifa_world_cup;

-- ------------------------------------------------------------
-- 1. COUNTRIES / TEAMS
-- ------------------------------------------------------------
CREATE TABLE Teams (
    team_id        INT AUTO_INCREMENT PRIMARY KEY,
    team_name      VARCHAR(50) NOT NULL UNIQUE,
    confederation  VARCHAR(10) NOT NULL CHECK (confederation IN ('UEFA','CONMEBOL','CONCACAF','CAF','AFC','OFC')),
    fifa_ranking   INT,
    coach_name     VARCHAR(60),
    home_kit_color VARCHAR(20)
);

-- ------------------------------------------------------------
-- 2. STADIUMS
-- ------------------------------------------------------------
CREATE TABLE Stadiums (
    stadium_id   INT AUTO_INCREMENT PRIMARY KEY,
    stadium_name VARCHAR(80) NOT NULL,
    city         VARCHAR(50) NOT NULL,
    country      VARCHAR(50) NOT NULL,
    capacity     INT NOT NULL CHECK (capacity > 0)
);

-- ------------------------------------------------------------
-- 3. REFEREES
-- ------------------------------------------------------------
CREATE TABLE Referees (
    referee_id   INT AUTO_INCREMENT PRIMARY KEY,
    referee_name VARCHAR(60) NOT NULL,
    country      VARCHAR(50) NOT NULL
);

-- ------------------------------------------------------------
-- 4. PLAYERS
-- ------------------------------------------------------------
CREATE TABLE Players (
    player_id      INT AUTO_INCREMENT PRIMARY KEY,
    team_id        INT NOT NULL,
    player_name    VARCHAR(60) NOT NULL,
    jersey_number  INT NOT NULL CHECK (jersey_number BETWEEN 1 AND 99),
    position       VARCHAR(20) NOT NULL CHECK (position IN ('Goalkeeper','Defender','Midfielder','Forward')),
    date_of_birth  DATE,
    is_captain     BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    UNIQUE (team_id, jersey_number)
);

-- ------------------------------------------------------------
-- 5. GROUPS (Group A, B, C ...)
-- ------------------------------------------------------------
CREATE TABLE Tournament_Groups (
    group_id   INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(5) NOT NULL UNIQUE   -- e.g. 'A','B','C'
);

-- ------------------------------------------------------------
-- 6. GROUP <-> TEAM mapping
-- ------------------------------------------------------------
CREATE TABLE Group_Teams (
    group_id INT NOT NULL,
    team_id  INT NOT NULL,
    PRIMARY KEY (group_id, team_id),
    FOREIGN KEY (group_id) REFERENCES Tournament_Groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id)  REFERENCES Teams(team_id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 7. MATCHES
-- ------------------------------------------------------------
CREATE TABLE Matches (
    match_id     INT AUTO_INCREMENT PRIMARY KEY,
    stage        VARCHAR(20) NOT NULL CHECK (stage IN
                   ('Group Stage','Round of 16','Quarter Final','Semi Final','Third Place','Final')),
    group_id     INT NULL,                      -- NULL for knockout matches
    team1_id     INT NOT NULL,
    team2_id     INT NOT NULL,
    stadium_id   INT NOT NULL,
    referee_id   INT NOT NULL,
    match_date   DATETIME NOT NULL,
    team1_score  INT DEFAULT 0,
    team2_score  INT DEFAULT 0,
    status       VARCHAR(15) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled','Completed','Postponed')),
    FOREIGN KEY (group_id)   REFERENCES Tournament_Groups(group_id),
    FOREIGN KEY (team1_id)   REFERENCES Teams(team_id),
    FOREIGN KEY (team2_id)   REFERENCES Teams(team_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums(stadium_id),
    FOREIGN KEY (referee_id) REFERENCES Referees(referee_id),
    CHECK (team1_id <> team2_id)
);

-- ------------------------------------------------------------
-- 8. GOALS
-- ------------------------------------------------------------
CREATE TABLE Goals (
    goal_id     INT AUTO_INCREMENT PRIMARY KEY,
    match_id    INT NOT NULL,
    player_id   INT NOT NULL,
    team_id     INT NOT NULL,
    goal_minute INT NOT NULL CHECK (goal_minute BETWEEN 1 AND 120),
    goal_type   VARCHAR(15) DEFAULT 'Normal' CHECK (goal_type IN ('Normal','Penalty','Own Goal','Free Kick')),
    FOREIGN KEY (match_id)  REFERENCES Matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    FOREIGN KEY (team_id)   REFERENCES Teams(team_id)
);

-- ------------------------------------------------------------
-- 9. CARDS (Yellow / Red)
-- ------------------------------------------------------------
CREATE TABLE Cards (
    card_id     INT AUTO_INCREMENT PRIMARY KEY,
    match_id    INT NOT NULL,
    player_id   INT NOT NULL,
    card_type   VARCHAR(10) NOT NULL CHECK (card_type IN ('Yellow','Red')),
    card_minute INT NOT NULL CHECK (card_minute BETWEEN 1 AND 120),
    FOREIGN KEY (match_id)  REFERENCES Matches(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- ------------------------------------------------------------
-- 10. GROUP STANDINGS (maintained via query/view, kept as table
--     here for simplicity in case triggers are used to update it)
-- ------------------------------------------------------------
CREATE TABLE Group_Standings (
    group_id        INT NOT NULL,
    team_id         INT NOT NULL,
    played          INT DEFAULT 0,
    won             INT DEFAULT 0,
    drawn           INT DEFAULT 0,
    lost            INT DEFAULT 0,
    goals_for       INT DEFAULT 0,
    goals_against   INT DEFAULT 0,
    goal_difference INT DEFAULT 0,
    points          INT DEFAULT 0,
    PRIMARY KEY (group_id, team_id),
    FOREIGN KEY (group_id) REFERENCES Tournament_Groups(group_id),
    FOREIGN KEY (team_id)  REFERENCES Teams(team_id)
);

-- Helpful indexes
CREATE INDEX idx_matches_date   ON Matches(match_date);
CREATE INDEX idx_players_team   ON Players(team_id);
CREATE INDEX idx_goals_player   ON Goals(player_id);
-- ------------------------------------------------------------
-- TEAMS
-- ------------------------------------------------------------
INSERT INTO Teams (team_name, confederation, fifa_ranking, coach_name, home_kit_color) VALUES
('Argentina', 'CONMEBOL', 1, 'Lionel Scaloni', 'Sky Blue/White'),
('France',    'UEFA',     2, 'Didier Deschamps', 'Blue'),
('Brazil',    'CONMEBOL', 3, 'Fernando Diniz', 'Yellow'),
('England',   'UEFA',     4, 'Gareth Southgate', 'White'),
('Spain',     'UEFA',     5, 'Luis de la Fuente', 'Red'),
('Germany',   'UEFA',     6, 'Julian Nagelsmann', 'White'),
('Morocco',   'CAF',      7, 'Walid Regragui', 'Red'),
('Japan',     'AFC',      8, 'Hajime Moriyasu', 'Blue');

-- ------------------------------------------------------------
-- STADIUMS
-- ------------------------------------------------------------
INSERT INTO Stadiums (stadium_name, city, country, capacity) VALUES
('Lusail Stadium',        'Lusail',    'Qatar', 88966),
('Al Bayt Stadium',       'Al Khor',   'Qatar', 60000),
('Education City Stadium','Al Rayyan', 'Qatar', 44667),
('Ahmad Bin Ali Stadium', 'Al Rayyan', 'Qatar', 44740);

-- ------------------------------------------------------------
-- REFEREES
-- ------------------------------------------------------------
INSERT INTO Referees (referee_name, country) VALUES
('Szymon Marciniak', 'Poland'),
('Antonio Mateu Lahoz', 'Spain'),
('Daniele Orsato', 'Italy'),
('Clement Turpin', 'France');

-- ------------------------------------------------------------
-- GROUPS
-- ------------------------------------------------------------
INSERT INTO Tournament_Groups (group_name) VALUES ('A'), ('B');

-- Group A: Argentina, Brazil, Morocco, Japan (team_id 1,3,7,8)
INSERT INTO Group_Teams (group_id, team_id) VALUES
(1, 1), (1, 3), (1, 7), (1, 8);

-- Group B: France, England, Spain, Germany (team_id 2,4,5,6)
INSERT INTO Group_Teams (group_id, team_id) VALUES
(2, 2), (2, 4), (2, 5), (2, 6);

-- ------------------------------------------------------------
-- PLAYERS (a few key players per team for demo purposes)
-- ------------------------------------------------------------
INSERT INTO Players (team_id, player_name, jersey_number, position, date_of_birth, is_captain) VALUES
-- Argentina (1)
(1, 'Lionel Messi', 10, 'Forward', '1987-06-24', TRUE),
(1, 'Emiliano Martinez', 23, 'Goalkeeper', '1992-09-02', FALSE),
(1, 'Rodrigo De Paul', 7, 'Midfielder', '1994-05-24', FALSE),
-- France (2)
(2, 'Kylian Mbappe', 10, 'Forward', '1998-12-20', FALSE),
(2, 'Hugo Lloris', 1, 'Goalkeeper', '1986-12-26', TRUE),
(2, 'Antoine Griezmann', 7, 'Forward', '1991-03-21', FALSE),
-- Brazil (3)
(3, 'Neymar Jr', 10, 'Forward', '1992-02-05', TRUE),
(3, 'Alisson Becker', 1, 'Goalkeeper', '1992-10-02', FALSE),
(3, 'Vinicius Junior', 7, 'Forward', '2000-07-12', FALSE),
-- England (4)
(4, 'Harry Kane', 9, 'Forward', '1993-07-28', TRUE),
(4, 'Jordan Pickford', 1, 'Goalkeeper', '1994-03-07', FALSE),
-- Spain (5)
(5, 'Alvaro Morata', 7, 'Forward', '1992-10-23', TRUE),
(5, 'Unai Simon', 23, 'Goalkeeper', '1997-06-11', FALSE),
-- Germany (6)
(6, 'Ilkay Gundogan', 21, 'Midfielder', '1990-10-24', TRUE),
(6, 'Manuel Neuer', 1, 'Goalkeeper', '1986-03-27', FALSE),
-- Morocco (7)
(7, 'Achraf Hakimi', 2, 'Defender', '1998-11-04', FALSE),
(7, 'Yassine Bounou', 1, 'Goalkeeper', '1991-04-05', TRUE),
-- Japan (8)
(8, 'Takefusa Kubo', 7, 'Forward', '2001-06-04', FALSE),
(8, 'Shuichi Gonda', 12, 'Goalkeeper', '1989-03-31', TRUE);

-- ------------------------------------------------------------
-- MATCHES (Group Stage examples)
-- ------------------------------------------------------------
INSERT INTO Matches (stage, group_id, team1_id, team2_id, stadium_id, referee_id, match_date, team1_score, team2_score, status) VALUES
('Group Stage', 1, 1, 8, 1, 1, '2026-06-14 16:00:00', 2, 1, 'Completed'),  -- Argentina vs Japan
('Group Stage', 1, 3, 7, 2, 2, '2026-06-14 19:00:00', 1, 1, 'Completed'),  -- Brazil vs Morocco
('Group Stage', 2, 2, 6, 3, 3, '2026-06-15 16:00:00', 3, 1, 'Completed'),  -- France vs Germany
('Group Stage', 2, 4, 5, 4, 4, '2026-06-15 19:00:00', 0, 0, 'Completed'),  -- England vs Spain
('Group Stage', 1, 1, 3, 1, 1, '2026-06-19 16:00:00', 2, 2, 'Completed'),  -- Argentina vs Brazil
('Group Stage', 2, 2, 4, 3, 2, '2026-06-19 19:00:00', 1, 0, 'Completed'),  -- France vs England
('Quarter Final', NULL, 1, 4, 1, 1, '2026-06-25 18:00:00', 0, 0, 'Scheduled'); -- Argentina vs England (example knockout)

-- ------------------------------------------------------------
-- GOALS
-- ------------------------------------------------------------
INSERT INTO Goals (match_id, player_id, team_id, goal_minute, goal_type) VALUES
(1, 1, 1, 23, 'Penalty'),   -- Messi
(1, 1, 1, 67, 'Normal'),    -- Messi brace
(1, 19, 8, 88, 'Normal'),   -- Kubo
(2, 7, 3, 34, 'Normal'),    -- Neymar
(2, 17, 7, 71, 'Normal'),   -- Hakimi
(3, 4, 2, 12, 'Normal'),    -- Mbappe
(3, 4, 2, 45, 'Normal'),    -- Mbappe brace
(3, 6, 2, 80, 'Free Kick'), -- Griezmann
(3, 15, 6, 90, 'Normal'),   -- Gundogan
(5, 1, 1, 10, 'Normal'),    -- Messi
(5, 9, 3, 55, 'Normal'),    -- Vinicius
(5, 7, 3, 60, 'Normal'),    -- Neymar
(5, 3, 1, 78, 'Normal'),    -- De Paul
(6, 4, 2, 30, 'Penalty');   -- Mbappe

-- ------------------------------------------------------------
-- CARDS
-- ------------------------------------------------------------
INSERT INTO Cards (match_id, player_id, card_type, card_minute) VALUES
(1, 3, 'Yellow', 40),
(2, 17, 'Yellow', 55),
(5, 9, 'Yellow', 66),
(6, 15, 'Red', 85);
