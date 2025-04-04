SELECT TABLE_SCHEMA AS `Database`, 
ROUND(SUM(DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS `Size (MB)` 
FROM information_schema.TABLES
GROUP BY TABLE_SCHEMA 
ORDER BY SUM(DATA_LENGTH + INDEX_LENGTH) DESC;
