clear all

close all

%% Operating Initializations for: Keyboard responses, Sounds, IOPort, Screen %%
%Setting up basic operations for MATLAB EEG Experiment
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%****Keyboard****%

%Sets the default numerical codes for each key button-press on the keyboard; 
KbName('UnifyKeyNames');

%Defines the 3 variables for: checking if the key is down, the time at 
% %keyboard check, and numerical code of the key that was pressed
[keyIsDown,keysecs,keyCode]=KbCheck;

%****Sound****%

%Sound card preparation
InitializePsychSound;

%Sets a call-able handle 'lfasound' to the audio operations
lfasound = PsychPortAudio('Open', [], [], 0, 22050, 2);

%****IOPort****%

%Creates a virtual serial port with call-able handle 'TPort' based on COM3 
%(check in Device Manager what the identity of the serial port is when 
%connecting the trigger box to confirm)
[TPort]=IOPort('OpenSerialPort','COM3','BaudRate=19200 DataBits=16 FlowControl=Hardware(RTS/CTS lines) SendTimeout=1.0 StopBits=1');

%****Screen****%
%Defines the basic colours of the screen: white, grey and black
%Other colours MUST BE DEFINED if you would like to use them
white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);

%Initializes the screen, gives the screen the call-able handle 'nwind1' and
%sets the variable 'rect' to be the screen resolution.
%rect is a 4-column variable with the 3rd-column being the width, and the 
%4th-column is the height it also fills the screen white (which was defined above)
[nwind1, rect]=Screen('OpenWindow',0,white);

%Sets default text size for the 'nwind' screen handle
Screen('TextSize',nwind1, 40);

%These variables determine the center of the screen based on the 'rect'
%variable and names them as v_res (vertical resolution) and h_res
%(horizontal), it also determines the center point of vertical and
%horizontal
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;

%Assigns 'fixation' to be a variable representing the center of the screen
fixation = [h_center-10 v_center-10];

%% Pre-stimulus development of: Sounds, Triggers, Keyboard assignment, and Stroop Matrix %%
%Setting up P3a sound stimuli and Stroop keys
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%Read's .wav files, assigns them to a two-column variable, 'stndy' and
%'stly' and takes the frequency from the startle wave file
[stndy, ~] = psychwavread('standard.wav');
[stly, freq] = psychwavread('start.wav');
[lfa1y, ~] = psychwavread('Stim_eyesclosed.wav');
[lfa2y, freq2] = psychwavread('Stim_eyesopen.wav');

%Transposes the variables to a two-row variable to be read by the
%PsychAudioPort, as a two-column variable cannot be played as a sound
stnd=stndy';
stl=stly';
lfa1=lfa1y';
lfa2=lfa2y';

%Naming and assigning values to our triggers stimuli (they must be 8-bit 
%integers) for more help search the 'uint8' function; 
%Note: it creates an 8-bit value from the number you put in, however because 
%it only has a max of 8-bits, the triggers number inputs will not be the
%number you get as a trigger output (e.g., uint8(17) will not appear as the 
%trigger number 17)
trig=uint8(0); %clears trigger
blstltrig=uint8(1); %baseline P300 startle
blstndtrig=uint8(2); %baseline P300 standard
mstltrig=uint8(4); %post manipulation startle
mstndtrig=uint8(5); %post manipulation standard
resptrig=uint8(9); %Stroop Response Trigger
congERNtrig=uint8(11); %congruent error
incongERNtrig=uint8(12); %incongruent error
congCRNtrig=uint8(14); %congruent correct
incongCRNtrig=uint8(15); %incongruent correct
slowtrig=uint8(7); %too slow response on Stroop

%This code creates a variable RED which will be the numerical representation
%of a physical keyboard button; use the function 'KbName('KEYBOARD BUTTON')' 
%to know how each key on the keyboard is represented numerically
RED=KbName('1!');

%Makes a row of 256 zeros
keypRED = zeros(1,256);

%Puts the number 1 at the column which represents the numerical value of
%the keyboard button you decided to represent the colour RED
keypRED ([RED]) = 1;


GREEN=KbName('2@');    
keypGREEN = zeros(1,256);
keypGREEN ([GREEN]) = 1;

BLUE=KbName('3#');
keypBLUE = zeros(1,256);
keypBLUE ([BLUE])=1;
        
YELLOW=KbName('4$');    
keypYELLOW = zeros(1,256);
keypYELLOW ([YELLOW])=1;

%Creates the variable 'keysOfInterest' which is a row of 256 zeros
keysOfInterest=zeros(1,256);

%Changes certain values in the specific columns of the 'keysOfInterest' to be
%1s insted of 0s, but only for the numerical key codes we have chosen as our 
%physical keyboard buttons (the buttons representing the colours R G B Y)
keysOfInterest([RED, GREEN, BLUE, YELLOW])=1;

%Creates a keyboard queue that only responds to the buttons we have defined
%in the 'keysOfInterest' variable
KbQueueCreate(-1, keysOfInterest);

%Initiates the keyboard queue
KbQueueStart; 

%Creates a 'cell' (only way we can store multiple string variables together) 
%that has the text stimuli that we want; this is done using curly
%brackets '{}'
WORDCOLORS = {'RED', 'GREEN', 'BLUE', 'YELLOW'};

%Creates a matrix where each row is a different RGB value
rgbColors = [255 0 0; 0 255 0; 0 0 255; 255 255 0];


%Setting up a 4 Colour and 4 Word Stroop Condition Matrix
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%Creates and sorts a repeating 1-4 column vector, 4x with 1 column 
%'STroopWorDs'; this will be needed to set up all permutations of words and
%colours
StWd = sort(repmat([1 2 3 4]',4,1));

%Creates a repeating 1-4 'column' vector, 4x with 1 column
%'STroopCoLours'; this will be combined with the words to create all
%possible combinations of colours and words
StCl = repmat([1 2 3 4]',4,1);

%Horizontal concatenation of the two column vectors we just created
%'FuLlCoNDition' matrix
FlCnd = horzcat(StWd,StCl);

%Creates a k variable that is the total number of rows of the FlCnd matrix
%which should be 16 in our 4 colour, 4 word example (will automaticallly be
%changed if you add more or fewer colours and words to the code above)
[k,~]=size(FlCnd);

% %Creates a for-loop that spans the total number of rows and separates the
% %congruent from the incongruent stimuli into separate variables, with 0's
% %as place holders 'ZeRosCoNGruent' 'ZeRosINCoNGruent'
   for i=1:k
       if FlCnd(i,1) == FlCnd(i,2);
          zrcng(i,:) = FlCnd(i,:);
       else
          zrincng(i,:)= FlCnd(i,:);
       end
   end
   
%Deletes all rows with 0s, creating a 'CONGruent' and 'INCONGruent' matrix
cong = zrcng(any(zrcng,2),:);
incong = zrincng(any(zrincng,2),:);

% 
% % %% Actual Experiment %%

m=4;%number of pages in consent form
%name of consent files

for i=1:m 
    icffile(i) = sprintf("C (%d).jpg",i);
    icfchar=char(icffile(1,i));
    icfo=imread(icfchar);
    icfimg{1,i}=imresize(icfo,0.45);
end

%For-Loop that processes presents each page with a button press%%

DrawFormattedText(nwind1,'Welcome to the Personality, Brain and Behaviour Experiment. \n \n If you have not already, please carefully read the consent form \n\n so that you fully understand your rights and role in this experiment. \n \n When you are ready to begin, press any button.','center','center',black);
Screen('Flip', nwind1);
KbStrokeWait;
 
for i=1:m
    icfbuffer=Screen('MakeTexture', nwind1, icfimg{1,i});
    Screen('DrawTexture', nwind1, icfbuffer, [], [], 0);
    DrawFormattedText(nwind1,'Press any key for the next page.', ['center'],[v_res-50]);
    Screen('Flip',nwind1);
    KbStrokeWait;
    WaitSecs(0.5);
end

consent = BinaryQuestion(nwind1, black, grey, 'I, the participant, consent to participate in this study.', 'Yes', 'No');
if consent == 2;
    sca;
end
Screen('FillRect', nwind1, white, rect);
Screen('Flip', nwind1,[],0); % clear screen
KbQueueRelease;
WaitSecs(.01);

ppnumb = OpenResponseQuestion(nwind1, black, white, 'Please enter your participant number', 1);
Screen('FillRect', nwind1, white);
Screen('Flip', nwind1); % clear screen
ListenChar(0);


% Records when the experiment begins
studystarttime=Screen('Flip',nwind1);

% Re-initiates the keyboard queue after receiving open response
% input, then flushes and keyboard presses just in case, but should be none
KbQueueCreate(-1, keysOfInterest);
KbQueueStart;
KbQueueFlush;

% Sets the volume for this experiment for the audio handle 'lfasound'
PsychPortAudio('Volume', lfasound, 1);

% %LFA BLOCK
%Draws text instructions on to the screen buffer (not yet shown)
Screen('FillRect', nwind1, white, rect);
Screen('Flip', nwind1,[],0); % clear screen
DrawFormattedText(nwind1,['First we will begin with a resting EEG measure. \n \n You will be given a fixation cross, please try to keep your eyes fixed \n'...
    'on the central cross the entire time. \n \n When you are ready to begin, press any button.'],  'center'  ,'center', black)
Screen('Flip', nwind1);
KbStrokeWait;
IOPort('Write',TPort,uint8(0));
%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind1, '+',  'center'  ,'center', black);
Screen('Flip', nwind1);
IOPort('Write',TPort,uint8(30));
WaitSecs(60);%DEBUG
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind1, white, rect);
Screen('Flip', nwind1,[],0); % clear screen
DrawFormattedText(nwind1, 'You''ve completed an ''eyes open'' baseline measure. \n Press any button to continue to an ''eyes closed'' baseline measure.',  'center'  ,'center', black);
Screen('Flip', nwind1,[],1); 
KbStrokeWait();
PsychPortAudio('FillBuffer', lfasound, lfa1);  
PsychPortAudio('Start', lfasound, 1, 0, 1);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind1, white, rect);
Screen('Flip', nwind1,[],0); % clear screen
IOPort('Write',TPort,uint8(40));
WaitSecs(60);%DEBUG
PsychPortAudio('FillBuffer', lfasound, lfa2);  
PsychPortAudio('Start', lfasound, 1, 0, 1);
IOPort('Write',TPort,uint8(0));
Screen('FillRect', nwind1, white, rect);
Screen('Flip', nwind1,[],0); % clear screen
DrawFormattedText(nwind1, 'You''ve completed the baseline calibration measure. \n Press any button to continue the experiment.',  'center'  ,'center', black);
Screen('Flip', nwind1,[],1); 
KbStrokeWait();
  Screen('FillRect', nwind1, white, rect);
  Screen('Flip', nwind1,[],0); % clear screen

% Draws text instructions on to the screen buffer (not yet shown)
DrawFormattedText(nwind1,['Now you will complete another calibration measure. \n \n'...
    'Try to keep your eyes fixed on the central cross.\n\n'...
' When you are ready to begin, press any button.'],'center','center',black);

% Anything drawn on the buffer gets 'flipped' on to the screen (every screen
% related drawing function above now gets shown)
Screen('Flip', nwind1,[],1);

% Waits for any button to be pressed
KbStrokeWait();

%Re-open PsychPortAudio with a callable handl 'audhand' for a different frequency (P300 sounds)
PsychPortAudio('Close', lfasound);
audhand = PsychPortAudio('Open', 9, [], 1, 48000, 2, [], 0.1); %Added DeviceID 10 for lowest latency sounds

% Draws a white rectangle on to the screen buffer (not yet shown)
Screen('FillRect', nwind1, white);

% Draws a fixation cross on the screen buffer (not yet shown)
DrawFormattedText(nwind1, '+',  'center'  ,'center', black);

% Anything drawn on the buffer gets 'flipped' on to the screen (every screen
% related drawing function above now gets shown)
Screen('Flip', nwind1,[],1); 

p3atrial=1

% ppdata=[blp3atrial, blp3atrialtype, postp3atrial, postp3atrialtype,
% prac button pressed, prac colour RGBcode, prac colour text, prac timing, main
% button pressed, main colour RGBcode, main colour text, main timing]
 pptdata={0,0,0,0,0,[0 0 0],'practice_colour_text','pracetice_response_correct',0,0,[0 0 0],'main_colour_text',0','response_correct'};

% EXP%% Baseline P3a Block %%EXP%%

for p3atrial=1:180 %DEBUG
    
    p3atrial_type =  randi(10);
    IOPort('Write',TPort,uint8(0));
    if p3atrial_type <= 2.
    wavedata = stl;
    trig = blstltrig;
    else
    wavedata = stnd;
    trig = blstndtrig;
    end
    pptdata(p3atrial,1)= {p3atrial};
    pptdata(p3atrial,2)= {p3atrial_type};
      
   
    PsychPortAudio('FillBuffer', audhand, wavedata);
    WaitSecs(1);
    PsychPortAudio('Start', audhand, 1, 0, 1);
    IOPort('Write',TPort,trig);
    WaitSecs(.01);
    
    
p3atrial = p3atrial+1;
end


Screen('FillRect', nwind1, white);
DrawFormattedText(nwind1, ['You''ve completed this additional baseline calibration measure. \n Next you will ' ...
    'be presented with some questionnaire items. \n Please complete the following questions in the browser.' ...
    '\n Press any button when you are ready to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind1,[],1); 
KbStrokeWait();

Screen('CloseAll'); 

url='https://ualbertapsychology.ca1.qualtrics.com/jfe/form/SV_3DdfcG0vRbUIbkN'
web(url,'-browser');

surveybutton1 = figure('Position',[680 558 200 80], 'numbertitle','off');
set(surveybutton1, 'MenuBar', 'none');
set(surveybutton1, 'ToolBar', 'none');
h = uicontrol('Position', [0 0 200 80], 'String', 'Press here once the survey is complete', ...
'Callback', 'uiresume(gcbf)');
uiwait(gcf);
close(surveybutton1);

[nwind2, rect]=Screen('OpenWindow',0,white);
Screen('TextSize',nwind2, 40);
DrawFormattedText(nwind2, ['You will now complete a second calibration measure. \n Please keep your eyes fixed on the '...
    'central cross the entire time. \n Press any button when you are ready to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind2,[],1); %flip it to the screen
KbStrokeWait();


Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2, '+',  'center'  ,'center', black);
Screen('Flip', nwind2,[],0); %flip it to the screen

%EXP%% Post-Manipulation P3a Block %%EXP%%

post_p3atrial=1


for post_p3atrial=1:180 %DEBUG
    
    
    post_p3atrial_type =  randi(10);
    IOPort('Write',TPort,uint8(0));
    if post_p3atrial_type <= 2
    wavedata = stl;
    trig=mstltrig;
    else
    wavedata = stnd;
    trig=mstndtrig;
    end
    
   pptdata(post_p3atrial,3)= {post_p3atrial};
   pptdata(post_p3atrial,4)= {post_p3atrial_type};
   PsychPortAudio('FillBuffer', audhand, wavedata);
   WaitSecs(1);     
   PsychPortAudio('Start', audhand, 1, 0, 1);
   IOPort('Write',TPort,trig);
   WaitSecs(.01);
post_p3atrial = post_p3atrial+1;
end


Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2, ['You''ve completed the second baseline calibration measure. \n Press any button'...
' to continue to the next task.'],  'center'  ,'center', black);
Screen('Flip', nwind2,[],0); 
KbStrokeWait();

%MORAL FOUNDATIONS QUESTIONNAIRE

Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2,'You will now answer some questions about your beliefs. \n \n Read each item carefully but do not over think your response \n\n just go with your gut reaction to each item. \n\n Press any key to continue.','center','center',black);
Screen('Flip', nwind2);
KbStrokeWait;
Screen('FillRect', nwind2, white, rect);
Screen('Flip', nwind2,[],0); % clear screen

    
    mft1{1} = 'In my judgements of morality: Whether or not someone suffered emotionally.';
    mft1{2} = 'In my judgements of morality: Whether or not some people were treated differently than others.';
    mft1{3} = 'In my judgements of morality: Whether or not someone’s action showed love for his or her country.';
    mft1{4} = 'In my judgements of morality: Whether or not someone showed a lack of respect for authority.';
    mft1{5} = 'In my judgements of morality: Whether or not someone violated standards of purity and decency.';
    mft1{6} = 'In my judgements of morality: Whether or not someone was good at math.';
    mft1{7} = 'In my judgements of morality: Whether or not someone cared for someone weak or vulnerable.';
    mft1{8} = 'In my judgements of morality: Whether or not someone acted unfairly.';
    mft1{9} = 'In my judgements of morality: Whether or not someone did something to betray his or her group.';
    mft1{10} = 'In my judgements of morality: Whether or not someone conformed to the traditions of society.';
    mft1{11} = 'In my judgements of morality: Whether or not someone did something disgusting.';
    mft1{12} = 'In my judgements of morality: Whether or not someone was cruel.';
    mft1{13} = 'In my judgements of morality: Whether or not someone was denied his or her rights.';
    mft1{14} = 'In my judgements of morality: Whether or not someone showed a lack of loyalty.';
    mft1{15} = 'In my judgements of morality: Whether or not an action caused chaos or disorder.';
    mft1{16} = 'In my judgements of morality: Whether or not someone acted in a way that God would approve of.';
      
    

q=16;


for i=1:q
    Likert(nwind2, black, mft1{i}, 'is not at all relevant', 'is extremely relevant', ...
    grey, 6, [], black,[]);
    dvmft1{1,i}=['mft1_' num2str(i)];
    dvmft1{2,i}=ans;
end

Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2,'You will now answer some more questions about your beliefs. \n \n Read each item carefully but do not over think your response \n\n just go with your gut reaction to each item. \n\n Press any key to continue.','center','center',black);
Screen('Flip', nwind2);
KbStrokeWait;
Screen('FillRect', nwind2, white, rect);
Screen('Flip', nwind2,[],0); % clear screen

    
%     Please read the following sentences and indicate your agreement or disagreement:
    mft2{1} = 'Compassion for those who are suffering is the most crucial virtue.';
    mft2{2} = 'When the government makes laws, the number one principle should be ensuring that everyone is treated fairly.';
    mft2{3} = 'I am proud of my country’s history.';
    mft2{4} = 'Respect for authority is something all children need to learn.';
    mft2{5} = 'People should not do things that are disgusting, even if no one is harmed.';
    mft2{6} = 'It is better to do good than to do bad.';
    mft2{7} = 'One of the worst things a person could do is hurt a defenseless animal.';
    mft2{8} = 'Justice is the most important requirement for a society.';
    mft2{9} = 'People should be loyal to their family members, even when they have done something wrong.';
    mft2{10} = 'Men and women each have different roles to play in society.';
    mft2{11} = 'I would call some acts wrong on the grounds that they are unnatural.';
    mft2{12} = 'It can never be right to kill a human being.';
    mft2{13} = 'I think it’s morally wrong that rich children inherit a lot of money while poor children inherit nothing.';
    mft2{14} = 'It is more important to be a team player than to express oneself.';
    mft2{15} = 'If I were a soldier and disagreed with my commanding officer’s orders, I would obey anyway because that is my duty.';
    mft2{16} = 'Chastity is an important and valuable virtue.';
    
    

q=16;


for i=1:q
    Likert(nwind2, black, mft2{i}, 'Strongly Disagree', 'Strongly Agree', ...
    grey, 6,[], black,[]);
    dvmft2{1,i}=['mft2_' num2str(i)];
    dvmft2{2,i}=ans;
end

fid = fopen([ppnumb 'MFQ.txt'],'w');
fprintf(fid,'%s,',dvmft1{1,:});
fprintf(fid,'%s,',dvmft2{1,:});
fprintf(fid,'\n');
fprintf(fid,'%d,',dvmft1{2,:});
fprintf(fid,'%d,',dvmft2{2,:});
fclose(fid);



Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2, 'RED\n  ''1''', [h_center-(h_center/4)], [v_center-25],[255 0 0]);
DrawFormattedText(nwind2, 'GREEN\n     ''2''', [h_center-(h_center/8)], [v_center-25],[0 255 0]);
DrawFormattedText(nwind2, 'BLUE\n   ''3''', [h_center+(h_center/10)], [v_center-25],[0 0 255]);
DrawFormattedText(nwind2, 'YELLOW\n      ''4''', [h_center+(h_center/4)], [v_center-25],[255 255 0]);

DrawFormattedText(nwind2, ['For this next task, you will be identifying the colour for different coloured words.'...
    '\n \n You will be using ONLY the keys on the keyboard which each represent'...
    '\n \n \n \n \n When a word appears you will press the button that '...
    'corresponds to the COLOUR of that word. \n You will first perform 12 practice trials and be given feedback '...
    'for each trial then, \n you will perform the main block with no feedback. \n \n When you are ready to begin, '...
    'press any button.'], 'center'  ,'center', black);
Screen('Flip', nwind2,[],1);
WaitSecs(.2);
KbStrokeWait();


%%EXP%% Practice Stroop Block %%EXP%%

blcong=datasample(cong,12);
blincong=datasample(incong,24);
blmat=vertcat(blcong,blincong);

for trial=1:12 %DEBUG
        
        
        sampbltrial=datasample(blmat,1,'Replace',false);        
        coloroftrial = rgbColors(sampbltrial(1,2),:);
        wordoftrial = WORDCOLORS(sampbltrial(1,1));
        IOPort('Write',TPort,uint8(0));
                
        Screen('FillRect', nwind2, white);
        DrawFormattedText(nwind2, '+',  'center'  ,'center', black);
        Screen('Flip', nwind2,[],1);
        WaitSecs(.5);
        Screen('FillRect', nwind2, white);
        DrawFormattedText(nwind2, wordoftrial{1,1},  'center'  ,'center', coloroftrial);
        starttime=Screen('Flip',nwind2);
        WaitSecs(.2);
        starttime=GetSecs;
        Screen('FillRect', nwind2, white);
        Screen('Flip',nwind2);
        [secs,keyCode]=KbWait([],2);
        IOPort('Write',TPort,resptrig);
        endtime=GetSecs;
         x=find(keyCode>0);
         timing=endtime-starttime;
         if timing > .8
             responsecolor=[0 0 0];
         else
            switch x
                case 49
                 responsecolor=[255 0 0];
                case 50
                 responsecolor=[0 255 0];
                case 51
                 responsecolor=[0 0 255];
                case 52
                 responsecolor=[255 255 0];
            end
         end
         
%Evaluates the keyboard response (compares key press to correct response)
%and gives feedback, and sends triggers accordingly (inc or cong trial, ERN
%or CRN, or too slow)

         if responsecolor==[0 0 0];
            DrawFormattedText(nwind2, 'TOO SLOW!',  'center'  ,'center', black);
            IOPort('Write',TPort,slowtrig);
            pptdata(trial,13)={'slow'};
        elseif        responsecolor == coloroftrial & sampbltrial(1,1)~=sampbltrial(1,2);
            DrawFormattedText(nwind2, 'CORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,incongCRNtrig);
            pptdata(trial,8)={'correct'};
        elseif        responsecolor == coloroftrial & sampbltrial(1,1)==sampbltrial(1,2);
            DrawFormattedText(nwind2, 'CORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,congCRNtrig);
            pptdata(trial,8)={'correct'};
         elseif sampbltrial(1,1)==sampbltrial(1,2);
            DrawFormattedText(nwind2, 'INCORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,congERNtrig);
            pptdata(trial,8)={'incorrect'};
        elseif  sampbltrial(1,1)~=sampbltrial(1,2);
            DrawFormattedText(nwind2, 'INCORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,incongERNtrig);
            pptdata(trial,8)={'incorrect'};
         end
         WaitSecs(.5);
         vbl=Screen('Flip',nwind2); 
        Screen('Flip',nwind2,vbl+1);
        pptdata(trial,5)={x};
        pptdata(trial,6)={coloroftrial};
        pptdata(trial,7)={wordoftrial};
        pptdata(trial,9)={timing};
        
end

                      
Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2, ['You''ve completed the practice block. You will now begin the main task.'...
    '\n For the next task you will complete 5 blocks of 36 trials each. \n Press any button to continue.']...
    ,  'center'  ,'center', black);
Screen('Flip', nwind2,[],1); 
KbStrokeWait();
Screen('FillRect', nwind2, white);
Screen('Flip',nwind2);


%%EXP%% Main Stroop Block %%EXP%%

 mcong=datasample(cong,12);
 mincong=datasample(incong,24);
 mmat=vertcat(mcong,mincong);
 
        block =0;
for block=0:4 %DEBUG
for mtrial=((36*block)+1):((36*block)+36) %DEBUG
        
        
        sampmtrial=datasample(mmat,1,'Replace',false);        
        mcoloroftrial = rgbColors(sampmtrial(1,2),:);
        mwordoftrial = WORDCOLORS(sampmtrial(1,1));
        IOPort('Write',TPort,uint8(0));
                
        Screen('FillRect', nwind2, white);
        DrawFormattedText(nwind2, '+',  'center'  ,'center', black);
        Screen('Flip', nwind2,[],1);
        WaitSecs(.5);
        Screen('FillRect', nwind2, white);
        DrawFormattedText(nwind2, mwordoftrial{1,1},  'center'  ,'center', mcoloroftrial);
        mstarttime=Screen('Flip',nwind2);
        WaitSecs(.2);
        mstarttime=GetSecs();
        Screen('FillRect', nwind2, white);
        Screen('Flip',nwind2);
        [msecs,mkeyCode]=KbWait([],2);
        IOPort('Write',TPort,resptrig);
        mendtime=GetSecs();
         mx=find(mkeyCode>0);
         mtiming=mendtime-mstarttime;
         if mtiming > .8
             mresponsecolor=[0 0 0];
         else
            switch mx
                case 49
                 mresponsecolor=[255 0 0];
                case 50
                 mresponsecolor=[0 255 0];
                case 51
                 mresponsecolor=[0 0 255];
                case 52
                 mresponsecolor=[255 255 0];
            end
         end
%Evaluates the keyboard response (compares key press to correct response)
%and gives feedback, and sends triggers accordingly (inc or cong trial, ERN
%or CRN, or too slow)
         if mresponsecolor==[0 0 0]           
            DrawFormattedText(nwind2, 'TOO SLOW!',  'center'  ,'center', black);
            IOPort('Write',TPort,slowtrig);
            pptdata(mtrial,14)={'slow'};
         elseif        mresponsecolor == mcoloroftrial & sampmtrial(1,1)==sampmtrial(1,2)            
            IOPort('Write',TPort,congCRNtrig);
            pptdata(mtrial,14)={'correct'};
         elseif        mresponsecolor == mcoloroftrial & sampmtrial(1,1)~=sampmtrial(1,2)          
            IOPort('Write',TPort,incongCRNtrig);
            pptdata(mtrial,14)={'correct'};
         elseif         sampmtrial(1,1)==sampmtrial(1,2)          
            IOPort('Write',TPort,congERNtrig);
            pptdata(mtrial,14)={'incorrect'};
         elseif        sampmtrial(1,1)~=sampmtrial(1,2)          
            IOPort('Write',TPort,incongERNtrig);
            pptdata(mtrial,14)={'incorrect'};
         end
         WaitSecs(.5);
         vbl=Screen('Flip',nwind2); 
        Screen('Flip',nwind2,vbl+1); 
        pptdata(mtrial,10)={mx};
        pptdata(mtrial,11)={mcoloroftrial};
        pptdata(mtrial,12)={mwordoftrial};
        pptdata(mtrial,13)={mtiming};
end
        block = block + 1
        
        DrawFormattedText(nwind2, ['You''ve completed ' num2str(block) ' out of 5 blocks. \n\n Press any key to continue'],...
        'center', 'center', black);
        Screen('Flip',nwind2);
        KbWait;
end

        
        append=[ppnumb 'stim.mat']; 
        save(append);
        
Screen('FillRect', nwind2, white);
DrawFormattedText(nwind2, ['You''ve completed the study. Thank you for your conscientious participation.'...
    '\n Press any button to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind2,[],1); 
KbStrokeWait();
Screen('FillRect', nwind2, white, rect);
Screen('Flip', nwind2); % clear screen

%Debrief

z=2;%number of pages in consent form
%name of consent files

for i=1:z
    dbffile(i) = sprintf("D (%d).jpg",i);
    dbfchar=char(dbffile(1,i));
    dbfo=imread(dbfchar);
    dbfimg{1,i}=imresize(dbfo,0.40);
end

%%For-Loop that processes presents each page with a button press%%


for i=1:z
    dbfbuffer=Screen('MakeTexture', nwind2, dbfimg{1,i});
    Screen('DrawTexture', nwind2, dbfbuffer, [], [], 0);
    DrawFormattedText(nwind2,'Press any key for the next page.', ['center'],[v_res-50]);
    Screen('Flip',nwind2);
    KbStrokeWait;
    WaitSecs(0.5);
end


DrawFormattedText(nwind2, ['We have one final request, please read the next form carefully. \n\nPress any key to continue'],  'center'  ,'center', black);
Screen('Flip', nwind2); 
KbStrokeWait();

    askemail=imresize((imread('Email.jpg')),.4);
    askemailbuffer=Screen('MakeTexture', nwind2, askemail);
    Screen('DrawTexture', nwind2, askemailbuffer, [], [], 0);
    DrawFormattedText(nwind2,'Press any key for the next page.', ['center'],[v_res-50]);
    Screen('Flip',nwind2);
    KbStrokeWait;
    WaitSecs(0.5);

ListenChar(0); 
ShowCursor(); 
Screen('CloseAll'); 