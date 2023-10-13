# Download latest WordPress version
Windows Powershell script to check for a new WordPress version, if there is one to download it and then to archive the previously downloaded version.

The script: 
- Checks for a new version
- If a new version exists, it downloads & extracts it and copies it to the `wordpress-latest` directory
- Archives the old version to a `wordpress-<OLD_VERSION_NUMBER>` directory
- Removes the default themes
- Removes the default plugins (Akismet & Hello Dolly)

It's set to download the en_GB version of WordPress, but you can change this by editing the `$locale` & $subDomain variables.

You can also change directory it saves it to by editing the "$destinationDir" variable.

It's designed to be run as a scheduled task which you can set up using the instructions below.

Note that this is the first PowerShell script I've written, so it's possibly not the most efficient way of doing things, but it works!

## Create Scheduled Task
To schedule the script to run once a day at a specific time, such as 10 am, you can use the Windows Task Scheduler. Here's how you can do it:

- **Open the Task Scheduler:**

    You can search for "Task Scheduler" in the Windows search bar and open it.
    In the Task Scheduler window, click on "Create Basic Task" in the right-hand panel.

- **Give your task a name, e.g. WordPressUpdateVersion, then click "Next."**

    Choose the "Daily" trigger and click "Next."

- **Set the start date and time to when you want the task to begin.** 

    e.g. set it to 10 am. Choose the "Recur every" option and set it to "1" day, then click "Next."

- **Select the "Start a Program" action and click "Next."**

- **In the "Program/script" field, provide the path to your PowerShell executable.** 

    Typically, this is located at "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe." In the "Add arguments (optional)" field, provide the path to your PowerShell script. For example:

    ```
    -ExecutionPolicy Bypass -File "C:\path\to\wordpress-versions\download-wordpress-latest.ps1"
    ```
    Replace "C:\path\to\wordpress-versions\download-wordpress-latest.ps1" with the actual path to your PowerShell script.

- **Click "Next" to review your settings.**

- **Finally, click "Finish" to create the task.**
