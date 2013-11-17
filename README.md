HCLocalize
==========

Localize Localizable.strings Files during Xcode Build

#### Installation

1.) Create Localizable.strings file at root of application (contains your strings)

2.) Create "Localized" folder at root of application

3.) Drag n' Drop "Localized" folder into Xcode application (be sure to reference folder - folder will be blue)

4.) Open Xcode and narrate to Project -> Targets -> ${Target Name} -> Build Phases

5.) Add New Run Script 

6.) Copy/Paste Localize.sh

#### Result

This go through your Localizable.strings (step #1) file and iterate through each string to translate and place in respective folder (Localized folder step #2). Thus, you'll have all of your localized folders (i.e. ru, es, nl, en, etc) bundled with your project. 
