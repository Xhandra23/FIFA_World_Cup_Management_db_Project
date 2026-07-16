# MySQL_FIFA_World_Cup_Management_db_Project

A MySQL-based FIFA World Cup Management System that manages teams, players, stadiums, referees, groups, matches, goals, cards, and standings. Features a normalized relational database, ER diagram, sample data, and 30+ SQL queries ranging from basic operations to advanced joins, window functions, and subqueries, demonstrating practical DBMS concepts.

## Project Overview

The FIFA World Cup Management System is a MySQL database project designed to manage teams, players,
stadiums, referees, groups, matches, goals, cards, and standings.

This project demonstrates:
- Database creation
- Relational database design
- Primary and Foreign Keys
- SQL query implementation
- Real-world tournament management workflow

## Technologies Used
- MySQL
- SQL

## Database Tables
1. Teams
2. Players
3. Stadiums
4. Referees
5. Tournament_Groups
6. Group_Teams
7. Matches
8. Goals
9. Cards
10. Group_Standings

## Relationships
- One team has many players.
- One team joins one group through Group_Teams.
- One team plays many matches (as team1 or team2).
- One stadium hosts many matches.
- One referee officiates many matches.
- One match produces many goals and many cards.
- One player scores many goals and receives many cards.
- One group has many teams ranked in Group_Standings.

## SQL Queries Included
- Basic Queries (10)
- Intermediate Queries (10)
- Advanced Queries (10)

## Features
- Team and squad management
- Player statistics tracking (goals, cards)
- Match scheduling and results
- Group stage standings calculation
- Stadium and referee assignment
- Golden Boot and disciplinary reports

## Learning Outcomes
- Relational database concepts
- SQL joins
- Aggregate functions
- Grouping and filtering
- Window functions and CTEs
- Database normalization

## Authors

| **Team Member**       | **Contribution**                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chandrasekhar** | Led the overall project development by designing the complete database architecture, creating SQL tables, defining primary and foreign key relationships, implementing constraints, developing Basic, Intermediate, and Advanced SQL queries, optimizing database performance, ensuring database normalization and data integrity, coordinating team activities, reviewing implementations, and preparing the final project documentation and README. |
| **Nikhil**             | Developed the Teams, Players, Stadiums, Referees, Group, Match, Goal, and Card modules, inserted realistic sample data, implemented database relationships, assisted in SQL query development, validated query outputs, ensuring database normalization and data integrity, coordinating team activities and contributed to debugging and successful integration of all project modules.                                                                                                             |
| **Rakesh**           | Designed the Entity-Relationship (ER) Diagram, verified relationships between database entities, reviewed SQL scripts for consistency, tested database integrity, assisted in debugging and validation, and supported the preparation of the final project report and presentation.                                                                                                                                                                  |
| **Kaushik**           | Developed the Intermediate and Advanced SQL query sets including joins, window functions, and CTEs, tested query outputs against sample data, documented query logic, and supported overall quality assurance and final report review.                                                                                                                                                                  |

## Conclusion

The FIFA World Cup Management System successfully demonstrates the practical implementation of a relational database using MySQL. The project provides an efficient solution for managing teams, players, stadiums, referees, matches, goals, cards, and standings through a well-structured and normalized database design. By implementing primary and foreign key relationships, the system ensures data integrity, minimizes redundancy, and maintains consistency across all interconnected tables.
