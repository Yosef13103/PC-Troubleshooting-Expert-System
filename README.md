# PC Troubleshooting Prolog System
Prolog code to help a user diagnose possible issues with their PC. Focusing mainly on Desktop computers, although can slightly apply to laptops as well. 
The system asks the user a question to which the user responds with the appropriate response. With each answer given, advice is returned on the next appropriate step the user must perform. All steps following the provided flowchart.

## Diagnostic Routes
System containing three main diagnosing paths, to specify each issue easily.

|ID | Diagnostic Routes | Descriptions |
| :-----: | :---: | :---: |
|P	| Power-On Self-Test | Failure	The PC is unable to boot due to a failed POST. |
|D	| No Display Output	 | The PC cannot output any display to the attached monitor(s). |
|L	| Device Performance Lagging | The PC opens but is slow and laggy, sometime to the point of crashing. |

## Running
Has to be run locally with SWI-Prolog installed on the machine and not sandboxed on a website.  
Type "Consult("PCTSE.pl")."  
Type "start."  

## End Result
After reaching an end case, the system will print out the steps taken and the answers provided, as well as the achieved diagnosis based on the users replies.
