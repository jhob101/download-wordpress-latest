# Download latest WordPress version
Powershell script to download latest WordPress version and archive old version

## Create Scheduled Task
To schedule the script to run once a day at a specific time, such as 10 am, you can use the Windows Task Scheduler. Here's how you can do it:

Open the Task Scheduler:

You can search for "Task Scheduler" in the Windows search bar and open it.
In the Task Scheduler window, click on "Create Basic Task" in the right-hand panel.

Give your task a name and description, then click "Next."

Choose the "Daily" trigger and click "Next."

Set the start date and time to when you want the task to begin. In your case, set it to 10 am. Choose the "Recur every" option and set it to "1" day, then click "Next."

Select the "Start a Program" action and click "Next."

In the "Program/script" field, provide the path to your PowerShell executable. Typically, this is located at "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe." In the "Add arguments (optional)" field, provide the path to your PowerShell script. For example:

```
-ExecutionPolicy Bypass -File "C:\path\to\your\script.ps1"
```
Replace "C:\path\to\your\script.ps1" with the actual path to your PowerShell script.

Click "Next" to review your settings.

Finally, click "Finish" to create the task.

You will be prompted to enter your Windows account credentials.

Once you've completed these steps, your PowerShell script will be scheduled to run daily at 10 am. Make sure your computer is on and not in sleep or hibernation mode when the scheduled time arrives.

You can also go back to Task Scheduler to view or modify your scheduled task if needed.
