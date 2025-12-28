-- Grant all privileges to expense_user on all expense_tracker databases
GRANT ALL PRIVILEGES ON `expense_tracker_%`.* TO 'expense_user'@'%';
FLUSH PRIVILEGES;
