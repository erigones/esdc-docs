Cron format is a flexible way to define time and frequency of running a periodic task. It is defined as a string of five fields separated by a space.

================= =========================
**Field name**    **Allowed values**
================= =========================
**Minutes**       0-59                
**Hours**         0-23                 
**Day of month**  1-31                 
**Month**         1-12 (January - December)
**Day of week**   0-6 (Sunday - Saturday)
================= =========================

**Examples**

* ``30 08 10 06 *`` - Run a task once every year on June 10 at 8:30 AM.
* ``00 11,16 * * *`` - Run a task twice a day at 11:00 AM and 4:00 PM.
* ``00 09-17 * * *`` - Run a task once every hour between 9:00 AM and 5:00 PM.
* ``00 09-18 * * 1-5`` - Run a task once every hour between 9:00 AM and 5:00 PM from Monday till Friday.
* ``* * * * *`` -  Run a task once every minute.
* ``0,10,20,30,40,50 * * * *`` - Run a task once every 10 minutes.
* ``0,2,4,6,8,10 * * * *`` - Run a task every 2 minutes during the first 10 minutes of a hour.
* ``0 0 1 1 *`` - Run a task once a year at midnight of January 1.
* ``0 0 * * *`` - Run a task once a day at midnight.
* ``0 * * * *`` - Run a task once an hour at the beginning of the hour.
