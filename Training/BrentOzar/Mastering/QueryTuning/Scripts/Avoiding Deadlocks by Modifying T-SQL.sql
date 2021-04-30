/*
Deadlocks - Left Window

Set up a couple of tables we'll use, and add a row to them: */

DROP TABLE IF EXISTS dbo.Lefty;
DROP TABLE IF EXISTS dbo.Righty;
GO
CREATE TABLE dbo.Lefty (Numbers INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.Lefty VALUES (1);
GO
CREATE TABLE dbo.Righty (Numbers INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.Righty VALUES (1);
GO


/* In the LEFT side window, lock dbo.Lefty: */
BEGIN TRAN
UPDATE dbo.Lefty
  SET Numbers = Numbers + 1;
GO
/* Notice that we didn't commit or roll back. We're holding our locks for now. */


/* Now switch over to the RIGHT side window, and follow the instructions. */







/* 
You're back! Now the RIGHT window has a lock on dbo.Lefty.
But let's try to continue our transaction, now trying to update Righty:
*/

UPDATE dbo.Righty
  SET Numbers = Numbers + 1;
GO


/* 
We're blocked by the RIGHT window, but as long as she commits or rolls back,
we could still theoretically work.

So go over to the RIGHT window...
*/






/* 
Welcome back! Let's roll back our transaction (if we were the one who won)
and then check sp_BlitzLock to see recent deadlocks:
*/
ROLLBACK
GO


/* 
Here's a free handy script to see deadlocks in the system health session in
SQL Server 2012 & newer. You don't have to do any prep - SQL Server is already
gathering this data for you.

You may have to run a few deadlocks to get 'em to show up though, then:
*/

sp_BlitzLock;
GO




/* 
In this case, how can we avoid deadlocks? It's simple: tweak the code.
Work on tables in exactly the same order. Start our transaction again:
*/
BEGIN TRAN
UPDATE dbo.Lefty
  SET Numbers = Numbers + 1;
GO
/* Notice that we didn't commit or roll back. We're holding our locks for now. */


/* Now switch over to the RIGHT side window, and follow the instructions. */







/* 
You're back! Now the RIGHT window has a lock on dbo.Lefty.
But let's try to continue our transaction, now trying to update Righty:
*/

UPDATE dbo.Righty
  SET Numbers = Numbers + 1;
GO


/* 
We're blocked by the RIGHT window, but as long as she commits or rolls back,
we could still theoretically work.

So go over to the RIGHT window...
*/








/* 
You're back! Our transaction can continue because the other window wasn't
able to take any locks that would slow us down. Now we can update Righty:
*/

UPDATE dbo.Righty
  SET Numbers = Numbers + 1;
GO


/* 
And we're done! Commit. Note that as soon as we commit, the RIGHT window will
instantly be able to move forward with his lock on Lefty.
*/
COMMIT
GO




/*
We still have a BLOCKING problem.

We just fixed the DEADLOCK problem. Queries don't fail.
Now you're back to tuning blocking in the normal ways.
*/






/* Clean up after ourselves: */

DROP TABLE dbo.Lefty;
DROP TABLE dbo.Righty;
GO




/* 
To learn more about this topic, here are a few links:

Error Handling in SQL Server:
http://www.sommarskog.se/error_handling/Part1.html
Deadlocks are something the application needs to handle: SQL Server just
doesn't automatically retry them for you. It's up to your app to listen for
the error codes to come back, then do error handling or retries based on
the error number. In this epic (long) series, Erland Sommarskog lays out the
kinds of errors to look for, and how to handle them.

Using sp_BlitzLock:
https://www.brentozar.com/archive/2017/12/introducing-sp_blitzlock-troubleshooting-sql-server-deadlocks/

How SELECTs can win deadlocks:
https://www.brentozar.com/archive/2018/04/can-selects-win-deadlocks/

Low priority index rebuilds:
https://www.brentozar.com/archive/2015/01/testing-alter-index-rebuild-wait_at_low_priority-sql-server-2014/
If your deadlocks involve index rebuilds, and you're on SQL Server 2014 or
newer, you can use a new parameter for your index rebuilds to have them
happen at a lower locking priority.



*/


/*
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
*/
MYSQL
/*
Deadlocks - Right Window

v1.0 - 2018-09-10

Open up Deadlocks - Lefty.sql first, and run the setup there.
Lefty's script will tell you when it's time to come over here.
*/


/* RIGHT SIDE: */

BEGIN TRAN
UPDATE dbo.Righty
  SET Numbers = Numbers + 1;
GO



/* Now, switch over to Lefty. */






/* 
Left would be okay IF we did a commit or a rollback.

We're not going to do that.

Instead, we're going to ask for a lock that Lefty already has. Righty won't be
able to make progress, and Lefty won't be able to make progress. Things will
happen fast:
*/

UPDATE dbo.Lefty
  SET Numbers = Numbers + 1;
GO



/* Roll back if this was the window that happened to win: */
ROLLBACK
GO








/*
This time, instead of locking dbo.Righty first, let's change the code.
We're going to do the same THINGS, but do them in different ORDER.
This time around, start with dbo.Lefty:
*/
BEGIN TRAN
UPDATE dbo.Lefty
  SET Numbers = Numbers + 1;
GO



/*
Note that we're blocked - we can't make progress.

But that's okay.

SQL Server will let this go on absolutely forever. No query will get killed.
Even better, this time around, we can't claim any locks on any tables that
might stop the left window from making progress. We're stopped in our
tracks right here.

Switch over to the left window...
*/







ROLLBACK
GO




/*
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
*/