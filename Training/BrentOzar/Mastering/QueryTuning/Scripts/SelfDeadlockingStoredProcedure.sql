/*
Mastering Query Tuning - Realistic Self-Deadlocking Stored Procedure

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/masterqueries


This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack




License: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
More info: https://creativecommons.org/licenses/by-sa/3.0/

You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license,
  and indicate if changes were made.
* ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.


This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO


CREATE OR ALTER PROC dbo.usp_CastUpVote
	@VoterId INT, @PostId INT AS
BEGIN

BEGIN TRAN
	/* Update the voter's LastAccessDate because they were active on Stack Overflow: */
	UPDATE dbo.Users
	  SET LastAccessDate = GETDATE()
	  WHERE Id = @VoterId;

	/* Cast an upvote: */
	INSERT INTO dbo.Votes (PostId, UserId, VoteTypeId, CreationDate)
	  VALUES (@PostId, @VoterId, 2, GETDATE());

	/* Update the post's score: */
	UPDATE dbo.Posts
	  SET Score = Score + 1
	  WHERE Id = @PostId;

	WAITFOR DELAY '00:00:10' /* 10 seconds */

	/* Grant a reputation point to the post's owner: */
	UPDATE u
	  SET Reputation = Reputation + 1
	  FROM dbo.Posts p
	  INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
	  WHERE p.Id = @PostId;

COMMIT;
END;
GO


/* Run these in two separate windows: */
EXEC usp_CastUpVote @VoterId = 8741, @PostId = 1251636;

EXEC usp_CastUpVote @VoterId = 149190, @PostId = 338156;
GO



/* Try moving both Users updates to the top: */
CREATE OR ALTER PROC dbo.usp_CastUpVote
	@VoterId INT, @PostId INT AS
BEGIN

BEGIN TRAN
	/* Update the voter's LastAccessDate because they were active on Stack Overflow: */
	UPDATE dbo.Users
	  SET LastAccessDate = GETDATE()
	  WHERE Id = @VoterId;

	WAITFOR DELAY '00:00:10' /* 10 seconds */

	/* Grant a reputation point to the post's owner: */
	UPDATE u
	  SET Reputation = Reputation + 1
	  FROM dbo.Posts p
	  INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
	  WHERE p.Id = @PostId;

	/* Cast an upvote: */
	INSERT INTO dbo.Votes (PostId, UserId, VoteTypeId, CreationDate)
	  VALUES (@PostId, @VoterId, 2, GETDATE());

	/* Update the post's score: */
	UPDATE dbo.Posts
	  SET Score = Score + 1
	  WHERE Id = @PostId;

COMMIT;
END;
GO



/* Run these in two separate windows: */
EXEC usp_CastUpVote @VoterId = 8741, @PostId = 1251636;

EXEC usp_CastUpVote @VoterId = 149190, @PostId = 338156;
GO



/* Try merging the two Users updates into one: */
CREATE OR ALTER PROC dbo.usp_CastUpVote
	@VoterId INT, @PostId INT AS
BEGIN

BEGIN TRAN
	/* Update both the voter and the question-owner */
	UPDATE u
	  SET LastAccessDate = CASE WHEN u.Id = @VoterId THEN GETDATE() ELSE u.LastAccessDate END,
	      Reputation = CASE WHEN u.Id = p.OwnerUserId THEN u.Reputation + 1 ELSE u.Reputation END
	  FROM dbo.Posts p
	  INNER JOIN dbo.Users u ON (p.OwnerUserId = u.Id OR u.Id = @VoterId)
	  WHERE p.Id = @PostId;

	WAITFOR DELAY '00:00:10' /* 10 seconds */

	/* Cast an upvote: */
	INSERT INTO dbo.Votes (PostId, UserId, VoteTypeId, CreationDate)
	  VALUES (@PostId, @VoterId, 2, GETDATE());

	/* Update the post's score: */
	UPDATE dbo.Posts
	  SET Score = Score + 1
	  WHERE Id = @PostId;

COMMIT;
END;
GO



/* Run these in two separate windows: */
EXEC usp_CastUpVote @VoterId = 8741, @PostId = 1251636;

EXEC usp_CastUpVote @VoterId = 149190, @PostId = 338156;
GO






/* Try doing one update outside of the transaction: */
CREATE OR ALTER PROC dbo.usp_CastUpVote
	@VoterId INT, @PostId INT AS
BEGIN
/* Update the voter's LastAccessDate because they were active on Stack Overflow: */
UPDATE dbo.Users
	SET LastAccessDate = GETDATE()
	WHERE Id = @VoterId;


BEGIN TRAN

	WAITFOR DELAY '00:00:10' /* 10 seconds */

	/* Grant a reputation point to the post's owner: */
	UPDATE u
	  SET Reputation = Reputation + 1
	  FROM dbo.Posts p
	  INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
	  WHERE p.Id = @PostId;

	/* Cast an upvote: */
	INSERT INTO dbo.Votes (PostId, UserId, VoteTypeId, CreationDate)
	  VALUES (@PostId, @VoterId, 2, GETDATE());

	/* Update the post's score: */
	UPDATE dbo.Posts
	  SET Score = Score + 1
	  WHERE Id = @PostId;

COMMIT;
END;
GO



/* Run these in two separate windows: */
EXEC usp_CastUpVote @VoterId = 8741, @PostId = 1251636;

EXEC usp_CastUpVote @VoterId = 149190, @PostId = 338156;
GO