-- 10. Social Media Analytics Dashboard 📱
-- Skills Used: SQL Aggregations, Window Functions, Data Warehousing
-- •	Tables: Users, Posts, Likes, Comments, Shares
-- •	Features:
-- o	Track user engagement metrics.
-- o	Generate reports on trending posts, top influencers.
-- o	Analyze user activity over time.
-- •	Advanced: Use BigQuery or Snowflake for large-scale analytics.

-- 1. Users
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE
);

-- 2. Posts
CREATE TABLE Posts (
    post_id INT PRIMARY KEY,
    user_id INT,
    content TEXT,
    post_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 3. Likes
CREATE TABLE Likes (
    like_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    liked_at DATETIME,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 4. Comments
CREATE TABLE Comments (
    comment_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment TEXT,
    commented_at DATETIME,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

 -- 5. Shares
 CREATE TABLE Shares (
    share_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    shared_at DATETIME,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 1. User Engagement Metrics
 SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT s.share_id) AS total_shares
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN Likes l ON p.post_id = l.post_id
LEFT JOIN Comments c ON p.post_id = c.post_id
LEFT JOIN Shares s ON p.post_id = s.post_id
GROUP BY u.user_id, u.username;

-- 2. Trending Posts (last 7 days)
SELECT 
    p.post_id,
    u.username,
    p.content,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) + COUNT(DISTINCT s.share_id) AS engagement_score
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
LEFT JOIN Likes l ON p.post_id = l.post_id AND l.liked_at >= NOW() - INTERVAL 7 DAY
LEFT JOIN Comments c ON p.post_id = c.post_id AND c.commented_at >= NOW() - INTERVAL 7 DAY
LEFT JOIN Shares s ON p.post_id = s.post_id AND s.shared_at >= NOW() - INTERVAL 7 DAY
WHERE p.post_date >= NOW() - INTERVAL 7 DAY
GROUP BY p.post_id, u.username, p.content
ORDER BY engagement_score DESC
LIMIT 10;

-- 3. Top Influencers (Window Function)
SELECT 
    user_id,
    username,
    total_engagement,
    RANK() OVER (ORDER BY total_engagement DESC) AS influencer_rank
FROM (
    SELECT 
        u.user_id,
        u.username,
        COUNT(l.like_id) + COUNT(c.comment_id) + COUNT(s.share_id) AS total_engagement
    FROM Users u
    LEFT JOIN Posts p ON u.user_id = p.user_id
    LEFT JOIN Likes l ON p.post_id = l.post_id
    LEFT JOIN Comments c ON p.post_id = c.post_id
    LEFT JOIN Shares s ON p.post_id = s.post_id
    GROUP BY u.user_id, u.username
) AS engagement_data;


INSERT INTO Users (user_id, username, email, signup_date) VALUES
(1, 'akash123', 'akash@example.com', '2023-01-15'),
(2, 'jane_doe', 'jane@example.com', '2023-03-10'),
(3, 'techguy', 'tech@example.com', '2023-06-25'),
(4, 'naturelover', 'nature@example.com', '2023-08-01');


INSERT INTO Posts (post_id, user_id, content, post_date) VALUES
(101, 1, 'Just finished my new SQL project!', '2025-04-01 10:00:00'),
(102, 2, 'Loving the new features on this platform.', '2025-04-03 14:25:00'),
(103, 3, 'Check out my latest tech review!', '2025-04-04 09:10:00'),
(104, 1, 'SQL tips and tricks coming soon...', '2025-04-05 18:20:00'),
(105, 4, 'Nature walks are the best therapy.', '2025-04-06 07:50:00');

INSERT INTO Likes (like_id, post_id, user_id, liked_at) VALUES
(201, 101, 2, '2025-04-01 11:00:00'),
(202, 101, 3, '2025-04-01 11:10:00'),
(203, 102, 1, '2025-04-03 15:00:00'),
(204, 103, 2, '2025-04-04 10:00:00'),
(205, 104, 3, '2025-04-05 20:00:00'),
(206, 105, 1, '2025-04-06 09:00:00');

INSERT INTO Comments (comment_id, post_id, user_id, comment, commented_at) VALUES
(301, 101, 2, 'Awesome project, Akash!', '2025-04-01 12:00:00'),
(302, 102, 3, 'Totally agree!', '2025-04-03 16:00:00'),
(303, 103, 1, 'Great review!', '2025-04-04 11:00:00'),
(304, 105, 2, 'So peaceful!', '2025-04-06 08:15:00');

INSERT INTO Shares (share_id, post_id, user_id, shared_at) VALUES
(401, 101, 3, '2025-04-01 13:00:00'),
(402, 103, 2, '2025-04-04 12:30:00'),
(403, 104, 4, '2025-04-05 21:00:00'),
(404, 105, 1, '2025-04-06 10:00:00');

SELECT * FROM Users;
SELECT * FROM Posts;
SELECT * FROM Likes;
SELECT * FROM Comments;
SELECT * FROM Shares;

