# Calabash GUI
Calabash GUI is a graphical user interface for the Calabash automated testing framework.

## Step By Step Instructions
1.  Use the radio buttons to select the OS you are testing (iOS or Android).
2.  Click the browse button and then select the directory that your calabash .feature files are located in.
3.  Depending on what OS you are testing browse for the directory of the Xcode project (iOS) or the APK (Android).
4. **(optional)** Browse for the directory that screenshots will be stored in that are taken during the test.
5. **(optional)** Type in the tags that you want to be ran for this test. For example to run two tags you would enter - @tagName1,@tagName2. If no tags are entered all feature files will be ran.
      
      **Don't forget the '@' symbol**

6. Choose whether to have the app restart or not between scenarios. For example if you are running progression scenarios that continue off of where another scenario left off you would select 'No Restart After Scenario'.

  **Note: Preventing restarts between scenarios requires modified launch.rb and app_life_cycle_hooks.rb for Android and iOS respectively**

  **If 'No Restart' is selected you must already have the simulator and app open, otherwise you must have the simulator closed**

7. **(optional)** To save the test, click the 'Save Current Test' button and choose a name and location.

8.  That's it! Just click the 'Start Test' button

      **Don't forget to follow the instructions in step 6 for whether or not to have your simulator open**

### Loading a Test
To load a test just click the 'Load Test' button and select a previously saved shell (.sh) file. The only setting that may need to be changes is the 'Calabash Feature Folder' since this is user specific.
