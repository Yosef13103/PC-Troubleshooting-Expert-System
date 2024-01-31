% to run the code:
% has to be run locally and not sandboxed on a website.
% consult("PCTSE.pl").
% then just type "start."

% Lists
% Stores the answers to each question in the form of Text, Answer
:- dynamic useranswers/2.
useranswers([],[]).

% Stores the RAM and CPU answers
:- dynamic ramanswers/1.
ramanswers([]).

:- dynamic cpuanswers/1.
cpuanswers([]).

% Keep track of the number of questions asked
:- dynamic questions_asked/1.
questions_asked(0).

% Main
start :-
    clear_lists,
    write("Welcome to the PC troubleshooting Expert System."), nl,
    write("Please answer the following questions to help us help you."), nl,
    write("You can also type quit to exit the system at any time."), nl,
    ask('bootup').

clear_lists :-
    retractall(useranswers(_, _)),
    retractall(ramanswers(_)),
    retractall(cpuanswers(_)).

ask(ItemId) :-
    (ItemId == 'quit' -> % Check if user wants to quit
        write("You have chosen to quit the PC troubleshooting Expert System."), nl,
        write("Thank you for your time"), nl,
        write("Please press any key to exit."), nl,
        clear_lists,
        read_line_to_string(user_input, _),
        halt)
    ; flow(ItemId, ItemText, _, _) -> % Check if flow/4 exists
        flow(ItemId, ItemText, YesItem, NoItem),
        write(ItemText), nl,
        printyesno,
        read_string(user_input, "\n", "\r\t ", _, Answer),
        string_lower(Answer, LowerAnswer), % Convert answer to lowercase
        ( (LowerAnswer == "quit"; LowerAnswer == "q")  -> ask('quit');
            (LowerAnswer == "yes"; LowerAnswer == "y") -> (store_useranswer(ItemText, "Yes"), ask(YesItem));
            (LowerAnswer == "no"; LowerAnswer == "n") -> (store_useranswer(ItemText, "No"), ask(NoItem));
            validate_input(Answer) -> ask(ItemId)
        )
    ; flow(ItemId, ItemText, _) -> % Check if flow/3 exists
        flow(ItemId, ItemText, _),
        write(ItemText), nl,
        (
            % For RAM and CPU calculation
            ItemId == 'ramspeed' -> ask_ram_speed;
            ItemId == 'ramcapacity' -> ask_ram_capacity;
            ItemId == 'cpuspeed' -> ask_cpu_speed;
            ItemId == 'cpucores' -> ask_cpu_cores;

            % For CPU Cooler
            ItemId == 'cooler' -> ask_cooler(ItemText)
        )
    ; flow(ItemId, ItemText) -> % Check if flow/2 exists
        write("\n"),
        write(ItemText), nl,
        (ItemId == 'confidence' -> get_confidence(Next), ask(Next);
        print_useranswers, nl,
        write("Thank you for using the PC troubleshooting Expert System."), nl,
        write("Please press any key to exit."), nl,
        clear_lists,
        read_line_to_string(user_input, _),
        halt).

% Functions
printyesno :-
    write(" - Yes"), nl,
    write(" - No"), nl.

validate_range_input(Input, Max) :-
    number_string(Number, Input),
    Number >= 1, Number =< Max.

validate_input(Answer) :-
    (Answer \= "yes", Answer \= "no", Answer \= "quit", Answer \= "y", Answer \= "n", Answer \= "q") -> writeln("Please answer with \"Yes\", \"No\" or \"Quit\" only.").

store_useranswer(Text, Answer) :-
    assert(useranswers(Text, Answer)).

print_useranswers() :-
    ( current_predicate(useranswers/2) -> % Check if there are any user answers stored
        write("Your answers were:"), nl,
        forall(useranswers(Text, Answer),
               (write("\t"), write(Text), write(': '), write(Answer), nl))
    ; true % If there are no user answers stored, do nothing
    ).

ask_cooler(ItemText) :-
    write("1- Air Cooler"), nl,
    write("2- AIO (Water Cooler)"), nl,
    read_string(user_input, "\n", "\r\t ", _, Answer),
    atom_number(Answer, NumberAnswer),
    ( validate_range_input(Answer, 2) ->
        (NumberAnswer == 1 -> store_useranswer(ItemText, "Air Cooler");
         NumberAnswer == 2 -> store_useranswer(ItemText, "AIO (Water Cooler)"));
        write("Invalid input. Please enter a number between 1 and 2."), nl, ask_cooler(ItemText) ),
    ask('LA7').

% Storing RAM and CPU Confidence ratings
store_ram_answer(Answer) :-
    % Retrieve the current list of RAM answers
    (ramanswers(CurrentAnswers) -> true ; CurrentAnswers = []),
    % Add the new answer to the list
    append(CurrentAnswers, [Answer], NewAnswers),
    % Store the updated list of RAM answers
    retractall(ramanswers(_)),
    assertz(ramanswers(NewAnswers)).

store_cpu_answer(Answer) :-
    % Retrieve the current list of CPU answers
    (cpuanswers(CurrentAnswers) -> true ; CurrentAnswers = []),
    % Add the new answer to the list
    append(CurrentAnswers, [Answer], NewAnswers),
    % Remove all existing CPU answers
    retractall(cpuanswers(_)),
    % Store the updated list of CPU answers
    assertz(cpuanswers(NewAnswers)).

% Asking RAM and CPU Questions
ask_ram_speed :-
    write("1- 2133MHz or Under"), nl,
    write("2- Between 2133MHz and 2667MHz "), nl,
    write("3- Between 2666MHz and 4000MHz"), nl,
    write("4- More than 4000Mhz"), nl,
    read_string(user_input, "\n", "\r\t ", _, Answer),
    ( validate_range_input(Answer, 4) -> store_ram_answer(Answer);
        write("Invalid input. Please enter a number between 1 and 4."), nl, ask_ram_speed ),
    ask('ramcapacity').

ask_ram_capacity :-
    write("1- Less than 4GB"), nl,
    write("2- 8GB to 16GB"), nl,
    write("3- 16GB to 32GB"), nl,
    write("4- More than 32GB"), nl,
    read_string(user_input, "\n", "\r\t ", _, Answer),
    ( validate_range_input(Answer, 4) -> store_ram_answer(Answer);
        write("Invalid input. Please enter a number between 1 and 4."), nl, ask_ram_capacity ),
    ask('cpuspeed').

ask_cpu_speed :-
    write("1- Less than 2.4GHz"), nl,
    write("2- 2.4GHz to 3.49GHz"), nl,
    write("3- 3.5GHz to 4.00GHz"), nl,
    write("4- More than 4.0GHz"), nl,
    read_string(user_input, "\n", "\r\t ", _, Answer),
    ( validate_range_input(Answer, 4) -> store_cpu_answer(Answer);
        write("Invalid input. Please enter a number between 1 and 4."), nl, ask_cpu_speed ),
    ask('cpucores').

ask_cpu_cores :-
    write("1- 4 Cores or less"), nl,
    write("2- 6 Cores"), nl,
    write("3- 8 Cores or more"), nl,
    read_string(user_input, "\n", "\r\t ", _, Answer),
    ( validate_range_input(Answer, 3) -> store_cpu_answer(Answer);
        write("Invalid input. Please enter a number between 1 and 3."), nl, ask_cpu_cores ),
    ask('confidence').

% Calculating RAM and CPU Confidence ratings
ramconfidence(RAMConfidence) :-
    % Retrieve the list of RAM answers
    ramanswers([RamSpeed, RamCapacity]),
    atom_number(RamSpeed, RamSpeedNum),
    atom_number(RamCapacity, RamCapacityNum),
    % Calculate the points for RAM speed
    (   RamSpeedNum == 1 -> SpeedPoints = 1.5, store_useranswer("[?] What is the MHz speed of your RAM?", "2133MHz or Under");
        RamSpeedNum == 2 -> SpeedPoints = 2.5, store_useranswer("[?] What is the MHz speed of your RAM?", "Between 2133MHz and 2667MHz ");
        RamSpeedNum == 3 -> SpeedPoints = 3.5, store_useranswer("[?] What is the MHz speed of your RAM?", "Between 2666MHz and 4000MHz");
        RamSpeedNum == 4 -> SpeedPoints = 4.5, store_useranswer("[?] What is the MHz speed of your RAM?", "More than 4000Mhz")
    ),
    % Calculate the points for RAM capacity
    (   RamCapacityNum == 1 -> CapacityPoints = 1.0, store_useranswer("[?] How many GBs of RAM do you have?", "Less than 4GB");
        RamCapacityNum == 2 -> CapacityPoints = 2.0, store_useranswer("[?] How many GBs of RAM do you have?", "8GB to 16GB");
        RamCapacityNum == 3 -> CapacityPoints = 3.0, store_useranswer("[?] How many GBs of RAM do you have?", "16GB to 32GB");
        RamCapacityNum == 4 -> CapacityPoints = 4.0, store_useranswer("[?] How many GBs of RAM do you have?", "More than 32GB")
    ),
    % Calculate the RAM confidence rating
    RAMConfidence is (SpeedPoints * CapacityPoints).

cpuconfidence(CPUConfidence) :-
    cpuanswers([CPUSpeed, CPUCores]),
    atom_number(CPUSpeed, CPUSpeedNum),
    atom_number(CPUCores, CPUCoresNum),
    % Calculate the points for CPU speed
    (   CPUSpeedNum == 1 -> SpeedPoints = 1.5, store_useranswer("[?] What is the speed of your CPU?", "Less than 2.4GHz");
        CPUSpeedNum == 2 -> SpeedPoints = 2.5, store_useranswer("[?] What is the speed of your CPU?", "2.4GHz to 3.49GHz");
        CPUSpeedNum == 3 -> SpeedPoints = 3.5, store_useranswer("[?] What is the speed of your CPU?", "3.5GHz to 3.99GHz");
        CPUSpeedNum == 4 -> SpeedPoints = 4.5, store_useranswer("[?] What is the speed of your CPU?", "More than 4.0GHz")
    ),
    % Calculate the points for CPU cores
    (   CPUCoresNum == 1 -> CorePoints = 1.0, store_useranswer("[?] How many cores does your CPU have?", "4 Cores or less");
        CPUCoresNum == 2 -> CorePoints = 2.0, store_useranswer("[?] How many cores does your CPU have?", "6 Cores");
        CPUCoresNum == 3 -> CorePoints = 3.0, store_useranswer("[?] How many cores does your CPU have?", "8 Cores or more")
    ),
    % Calculate the CPU confidence rating
    CPUConfidence is (SpeedPoints * CorePoints).

get_confidence(Next) :-
    % get the RAM and CPU confidence ratings
    ramconfidence(RAMConfidence),
    cpuconfidence(CPUConfidence),
    % check if RAMConfidence is less than 7, if it is write that it needs to be replaced
    (   RAMConfidence < 7 -> write("-Your RAM needs to be upgraded.\n");
        RAMConfidence >= 7 -> write("-Your RAM is fine.\n")),
    % check if CPUConfidence is less than 7, if it is write that it needs to be replaced
    (   CPUConfidence < 7 -> write("-Your CPU needs to be upgraded.\n"), nl;
        CPUConfidence >= 7 -> write("-Your CPU is fine.\n"), nl),
    % if at least one of them is less than 7 then return LC6 end case
    (   RAMConfidence < 7; CPUConfidence < 7) -> Next = 'LC6'; Next = 'cputemp',
    ask(Next).

% --------------------------------------------------FACTS--------------------------------------------------

% Advice and Instructions
    % General Advice
    flow('PGA1', "-[!] Try to reset the BIOS by reseating the CMOS battery. Did that fix the issue?", 'GC1', 'PGA2').
    flow('PGA2', "-[!] Test every stick of RAM you have by placing each in different slots. Did that fix the issue?", 'GC2', 'PGA3').
    flow('PGA3', "-[!] Update any and all software, whether this is the BIOS, the OS, the drivers, ect. Reinstall if possible. Did that fix the issue?", 'GC3','PA7').

    flow('DGA1', "-[!] Try to reset the BIOS by reseating the CMOS battery. Did that fix the issue?", 'GC1', 'DA2').
    flow('DGA2', "-[!] Test every stick of RAM you have by placing each in different slots. Did that fix the issue?", 'GC2', 'WC').

    flow('LGA3', "-[!] Update any and all software, whether this is the BIOS, the OS, the drivers, ect. Reinstall if possible. Did that fix the issue?", 'GC3', 'WC').

    % POST Diagnosis Advice
    flow('PA1', "-[!] Plug the PC into an outlet and make sure the power button on the power supply is switched on. Did that fix the issue?", 'PC1', 'PA2').
    flow('PA2', "-[!] Try a different wall outlet. Did that fix the issue?", 'PC2', 'PA3').
    flow('PA3', "-[!] Try a different IEC C13 Power Cable to connect to the outlet, ensure that it is similar to the original as much as possible. Did that fix the issue?", 'PC3', 'PA4').
    flow('PA4', "-[!] Make sure the front panel connectors are connected to the motherboard correctly. Did that fix the issue?", 'PC4', 'errorcodes').
    flow('PA5', "-[!] Disconnect all peripherals from the PC. Did that fix the issue?", 'PA6', 'PGA1').
    flow('PA6', "-[!] Reconnect each peripheral one by one to check for a faulty peripheral. Did that fix the issue?", 'PC7', 'PGA1').
    flow('PA7', "-[!] Only connect the power cables for the CPU and the Motherboard, ensure they are properly connected. Did that fix the issue?", 'PA8', 'sparePSU').
    flow('PA8', "-[!] Reconnect each of the previously disconnected cables to their respective hardware and check if the PC opens with each new connection. Did that fix the issue?", 'hardwareprevent', 'hardwareprevent').
    flow('PA9', "-[!] Unplug the old power supply along with all its cables and use the replacement one with all its cables. Did that fix the issue?", 'PC8', 'PC9').

    % Display Diagnosis Advice
    flow('DA1', "-[!] Make sure the monitor is plugged into the wall outlet and that the power button is switched on. Did that fix the issue?", 'DC1', 'DGA1').
    flow('DA2', "-[!] Try a different cable from the PC to the monitor. Did that fix the issue?", 'DC2', 'sparemonitor').
    flow('DA3', "-[!] Replace your current monitor with a different one. Did that fix the issue?", 'DC3', 'dGPU').
    flow('DA4', "-[!] Plug the monitor into the iGPU through the motherboard. Did that fix the issue?", 'DC4', 'DC6').
    flow('DA5', "-[!] Plug the monitor into the dGPU. Did that fix the issue?", 'DC5', 'spareGPU').
    flow('DA6', "-[!] Install the spare GPU into the system. Did that fix the issue?", 'DC4', 'DGA2').

    % Lagging Diagnosis Advice
    flow('LA1', "-[!] Replace the OS Hard Disk Drive with a Solid State Drive. Did that fix the issue?", 'LC1', 'xmp').
    flow('LA2', "-[!] Run an antivirus and anitmalware check on the device. Did that fix the issue?", 'LC2', 'xmp').
    flow('LA3', "-[!] Enable XMP profiles on the RAM in the BIOS. Did that fix the issue?", 'LC3', 'ramchannel').
    flow('LA4', "-[!] Disable XMP profiles on the RAM in the BIOS. Did that fix the issue?", 'LC4', 'ramchannel').
    flow('LA5', "-[!] Switch to user Dual/Quad Channel memory. Did that fix the issue?", 'LC5', 'ramspeed').
    flow('LA6', "-[!] Replace the thermal paste on the CPU. Did that fix the issue?", 'LC7', 'cooler').
    flow('LA7', "-[!] Replace any fans. Did that fix the issue?", 'LC8', 'LC9').

% Questions
    % General Questions
    flow('bootup', "[?] Does the device boot up?", 'displayoutput', 'powerplugged').
    flow('displayoutput', "[?] Is there a display output?", 'lagging', 'monitoroff').
    flow('lagging', "[?] Does the device feel slow and lag a lot? Sometimes to the point of crashing?", 'bootstorage', 'BC').

    % POST Diagnosis Questions
    flow('powerplugged', "[?] Is the power cable plugged into the outlet?", 'PA2', 'PA1').
    flow('errorcodes', "[?] Do you hear beeping or does your motherboard show error codes?", 'PC5', 'burning').
    flow('burning', "[?] Did you notice anything irregular prior to the issue occuring such as a burning smell, sparks, and/or smoke?", 'PC6', 'PA5').
    flow('sparePSU', "[?] Do you have access to another usable power supply?", 'PA9', 'WC').

    % Display Diagnosis Questions
    flow('monitoroff', "[?] Is the monitor off?", 'DA1', 'DGA1').
    flow('sparemonitor', "[?] Do you have an extra monitor available?", 'DA3', 'dGPU').
    flow('dGPU', "[?] Do you have a dedicated GPU?", 'dGPUconnected', 'spareGPU').
    flow('dGPUconnected', "[?] Is the monitor connected to the dedicated GPU?", 'integratedGPU', 'DA5').
    flow('integratedGPU', "[?] Do you have an integrated GPU?", 'DA4', 'spareGPU').
    flow('spareGPU', "[?] Do you have access to a spare/borrowed GPU?", 'DA6', 'DGA2').

    % Lagging Diagnosis Questions
    flow('bootstorage', "[?] Do you have a HDD as your primary storage device for OS booting?", 'LA1', 'LA2').
    flow('xmp', "[?] Do you have XMP enabled?", 'LA4', 'LA3').
    flow('ramchannel', "[?] Are you using Dual/Quad Channel?", 'ramspeed', 'LA5').
    flow('cputemp', "[?] Monitor the temperature of the system. Is the CPU temperature over 65 degree celsius at idle?", 'LA6', 'LGA3').
    % flow/3
        flow('ramspeed', "[?] What is the MHz speed of your RAM?", 'ramcapacity').
        flow('ramcapacity', "[?] How many GBs of RAM do you have?", 'cpuspeed').
        flow('cpuspeed', "[?] How many GHz is your CPU?", 'cpucores').
        flow('cpucores', "[?] How many cores does your CPU have?", 'confidence').
        flow('cooler', "[?] Are you using an AIO (Water Cooler) or an Air Cooler?", 'LA7').
    % flow/2
        flow('confidence', "Based on the replies you have given about your CPU and RAM, we have determined that").

% End Cases
    % General End Cases
    flow('BC', "[*] No issues that the Expert System is designed to help with. Suggest that if the user is still experiencing an issue, go to an outside source, such as a PC Repair Shop, for further help.").
    flow('WC', "[*] The Expert System cannot reach a suitable diagnosis with the information provided. Multiple parts of the PC may be at fault here. Suggest going to an outside source, such as a PC Repair Shop, for further help.").
    flow('GC1', "[*] By taking out the CMOS battery, the BIOS is reset back to the default configuration.").
    flow('GC2', "[*] One or more RAM sticks or RAM slots on the motherboard are faulty. The user needs to test each slot and each stick individually to confirm which specific stick/slot is causing the issue. It is recommended to replace the faulty stick or motherboard.").
    flow('GC3', "[*] At least one computer software was out of date and required an urgent update and/or reinstall to fix the issue, this could be the BIOS, the OS, drivers, or more.").

    % POST Diagnosis End Cases
    flow('PC1', "[*] The device was not plugged into an outlet.").
    flow('PC2', "[*] There is a possibility that the wall outlet the user has plugged the pc in is faulty. Trying a different wall outlet solved the issue.").
    flow('PC3', "[*] The cable the user was using to connect the PC to the wall outlet could be faulty.").
    flow('PC4', "[*] The front panel connectors were not connected to the motherboard correctly. The user should check the manual for the motherboard to ensure that the front panel connectors are connected correctly.").
    flow('PC5', "[*] The user should check the error code or beeping code using the motherbaord manual to figure out the issue from there.").
    flow('PC6', "[*] Stop using the PC immediately. Try to disable all the power cables from the components. Go to an experienced technician to dispose of the power supply and salvage any usable parts.").
    flow('PC7', "[*] One or more of the peripherals/hardware components connected to the PC are faulty. The user needs to test each peripheral/hardware component individually to confirm which specific component is causing the issue. It is recommended to replace the faulty component.").
    flow('PC8', "[*] The users main power supply is faulty.").
    flow('PC9', "[*] It is possible that either the motherboard or the CPU have a fault preventing a start up. Suggest to go to a technician.").

    % Display Diagnosis End Cases
    flow('DC1', "[*] The monitor was not plugged into an outlet.").
    flow('DC2', "[*] The cable the user was using to connect the PC to the monitor could be faulty.").
    flow('DC3', "[*] There is an issue with the monitor the user uses to display the PC output. If the monitor has more than one display input slot, they should test the display with these slots. If that does not help, then a new monitor is required.").
    flow('DC4', "[*] The Discrete Graphics Card is faulty and does not output a display signal correctly. If the dGPU has more than one display output slot, they should test each one. If that does not help, then a new dGPU is required.").
    flow('DC5', "[*] The user has a Discrete Graphics Card in their system, but instead, had connected the monitor cable directly to the motherboard, using the Integrated Graphics Card instead. The user could either believe their CPU has an iGPU or the iGPU is faulty. Simply connect the cable to the dGPU to fix the issue.").
    flow('DC6', "[*] One of three possible cases. The iGPU inside the CPU is faulty, the display output slot on the motherboard is broken, or the user mistakenly thinks their CPU has an iGPU. It will require further testing to determine the main issue. Suggested to take to a PC repair shop to assist further.").

    % Lagging Diagnosis End Cases
    flow('LC1', "[*] Replace the OS drive using a HDD with an SSD. SDDs are faster and more reliable than HDDs. Significantly increasing performance of the system.").
    flow('LC2', "[*] Users device was infected with malicious programs leading to a slow computer.").
    flow('LC3', "[*] The RAM is not running at its full speed. This can be fixed by enabling XMP profiles in the BIOS.").
    flow('LC4', "[*] XMP profiles are used to increase the speed of the RAM. This is done by increasing the voltage and clock speed of the RAM. This can lead to instability in the system.").
    flow('LC5', "[*] Dual/Quad Channel memory allows the RAM to run faster. This is done by using two or four sticks of RAM in the appropriate slots. Check the motherboard manual to confirm which slots allow for Dual Channel.").
    flow('LC6', "[*] There are components struggling to keep up with the rest of the systems hardware. The user should try to upgrade to improve performance.").
    flow('LC7', "[*] The CPU was running at a high temperature. This was fixed by replacing the thermal paste.").
    flow('LC8', "[*] One or more fans were not working correctly. This was fixed by replacing the faulty fans.").
    flow('LC9', "[*] The CPU is running at a high temperature. Changing the CPU Cooler whether AIO or Air cooler should fix this.").
