% Filmfest_online_importancerating.m
% rating the subjective importance of each movie scene from the 10 filmfest
% movies while watching the movies for the first time (to be compared to
% the importance ratings collected "after" watching the movies)
% 4/2/2019 hongmi lee

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  handling errors
function Filmfest_online_importancerating(varargin)

try
    addpath(genpath('/Users/hlee239/Documents/MATLAB/Psychtoolbox-3-PTB_Beta-2019-04-01_V3.0.15/Psychtoolbox'));
    main(varargin{:});
catch me % error handling
    ListenChar(0);
    fclose('all');
    Screen('CloseAll');
    ShowCursor();
    
    fprintf(2, '\n\n???:: %s\n\n', me.message); % main error message
    for k = 1:(length(me.stack) - 1)
        current = me.stack(k);
        fprintf('Error in ==> ');
        fprintf('<a href="matlab: opentoline(''%s'',%d,0)">%s at %d</a>\n\n',...
            current.file, current.line, current.name, current.line);
    end
end
return

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  main experiment

function main(varargin)

% clc;
clearvars;
fclose all;
ClockRandSeed;

Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');

global w cx cy textsize textcolor

%% get user parameters

prompt = {'SN: ','Initial (e.g., HM): ','Start from: ', 'Debug?: '};
defaults = {'99','','1','0'};
answer = inputdlg(prompt, 'Subject Information',1,defaults);
if isempty(answer)
    return
end

[SN, NM, STARTMV, DEBUG] = deal(answer{:});

if str2double(SN)<10
    SN=['0' SN];
end%if str2num

%% open file

dataDir  = 'data'; 
if ~exist(dataDir, 'dir') 
    mkdir(dataDir)
end

datafName = [dataDir '/' 'Filmfest_online_importance_' SN '_' NM '.csv'];
dataFile  = fopen(datafName, 'a');

SN=str2double(SN); STARTMV=str2double(STARTMV); DEBUG=str2double(DEBUG); 

%% keyboard setup

KEYNUM  = [KbName('0)') KbName('1!') KbName('2@') KbName('3#') KbName('4$') ...
           KbName('5%') KbName('6^') KbName('7&') KbName('8*') KbName('9(')];
KEYENTER= KbName('p'); 
KEYDEL  = KbName('DELETE'); 
KEYGO   = KbName('space'); % go on (for subjects)

%% stimulus setup

nMovie = 10;
moviedir = [pwd '/stim'];

for m = 1:nMovie
    moviefnames{m} = [moviedir '/FilmFest_' num2str(m) '.mp4'];
end

movobj = VideoReader(moviefnames{1});

% movie frame dimensions
height = movobj.Height;
width = movobj.Width;

% movie scene start times, first scene = 0 (title)
sceneStartTimes = {[0 5.4 17.5 29.15 69 93 101.4 128 150 169.7 198.6 217 230 239.5 251.9 263.9 283 296.91 303 310 321 329 334.9],...
    [0 11 16 25.3 29.2 40 45.1 52 69.2 83 94 100 122 131],...
    [0 33 47 72 93 107 121 147 168 184 200.5 218 249.6 290 294.3 321 342 345.3 353 372 380 400 408 438 448],...
    [0 25.7 45.7 47.8 54.3 59.2 64.3 70 92.7 99.2 102 113.2],...
    [0 17.15 20.6 38.5 57.2 69.03 82 94.47 109.07 117 126.07 140.07 152.43 172.67 188.5 210.23 222.13 233.9 259 267.73 280.4 284.73 303.2 315.53 337.67],...
    [0 9.23 25.56 35.66 45.06 62.73 77.66 99 106.5 116.3 127.9 138.2 144.1 157.7 170.3 183.35 194.1 200.1 205.7 221.6 229.3 248.3 259.6 266.7 276.7 288.2 306.4],...
    [0 17.86 25 40 60 81 87.5 100 131 150.4 178.6 199.6 207.8 232.8 243.5 252.2],...
    [0 21 35 40.9 64 73 91 103.8 130.7 138],...
    [0 7.6 17 35.4 42.8 47 52.2 59.65 68 88.8 105 116.3 135 148.5 156.5],...
    [0 31.06 49.8 58.8 66.56 82 101.8 108.6 116.03 129.3 131.76 144.5 153 167.4 174.56 181.76 194.5 213.13 219.9 226.5 235.93 242.3 250.16 262 265.23 279.8 288.96 314.86 320.63 328.33 339.7 343.43 375.43 383.26 409]};

% sceneStartTimes = {[0 6 18 30 68 93 102 128 151 170 201 218 230 238 252 264 283 297 304 309 322 330 335],...
%     [0 12 17 27 30 40 46 53 69 85 94 101 123 134],...
%     [0 34 46 73 94 108 122 149 169 184 200 220 250 292 295 323 342 345 354 372 381 400 408 438 448],...
%     [0 25 45 49 55 59 68 72 94 99 103 114],...
%     [0 18 21 39 57 70 83 94 110 118 126 141 153 173 189 211 222 234 259 269 280 286 303 316 339],...
%     [0 10 25 35 45 63 77 99 106 116 128 139 143 158 170 184 194 201 205 222 229 249 260 267 275 289 306],...
%     [0 18 26 41 61 81 88 100 132 150 180 200 209 232 245 253],...
%     [0 21 36 41 64 73 91 104 130 138],...
%     [0 7 18 36 43 49 53 60 68 89 105 117 135 149 157],...
%     [0 32 50 58 67 82 102 109 117 130 132 145 153 168 174 182 194 213 220 227 236 243 250 263 266 280 288 315 321 329 340 344 376 384 409]};

% total duration of each movie in seconds
moviedur = [350 138 469 135 357 329 265 146 165 424]; 

%% screen setup & open window

ListenChar(2);
HideCursor;

bcolor    = 0;
textcolor = 200;
textfont  = 'Arial';
textsize  = 24;

screenid = max(Screen('Screens'));

if DEBUG
    [w, screensize] = Screen('OpenWindow',screenid, bcolor, [0 0 1024 768]);
else
    [w, screensize] = Screen('OpenWindow',screenid, bcolor);
end
Screen(w, 'TextFont', textfont);
Screen(w, 'TextSize', textsize);
Screen(w, 'TextColor', textcolor);

screenX = screensize(3);
screenY = screensize(4);

cx = screenX/2;
cy = screenY/2;

screen_adj = .8; % frame dimension adjustment ratio (how big you want the movie to appear on the screen)
screenXadj = screenX*screen_adj;
screenYadj = screenXadj/(width/height); % movie aspect ratio regardless of ratio of whole display screen

%% load movie stimuli

for m = 1:nMovie
    moviepointers(m) = Screen('OpenMovie', w, moviefnames{m});
end

%% show movies

for m = STARTMV:nMovie
    
    % show instruction
    centerTXT('Watch the movie and rate the importance of each segment of the movie.', 0, -20);
    centerTXT(['Press the spacebar to play Movie ' num2str(m) '.'], 0, 20);
    Screen('Flip', w);
    
    % play movie
    movieStartTime = pressThisKey(KEYGO);
    tic
    
    for scene = 1:numel(sceneStartTimes{m})
        
        Screen('SetMovieTimeIndex', moviepointers(m), sceneStartTimes{m}(scene));
        Screen('PlayMovie',  moviepointers(m), 1, 0, 1.0);
        thisscenestart = GetSecs;
        
        % duration of each scene
        if scene == numel(sceneStartTimes{m})
            scenedur = moviedur(m)-sceneStartTimes{m}(scene);
        else
            scenedur = sceneStartTimes{m}(scene+1)-sceneStartTimes{m}(scene);
        end
        
        % show movie frames
        while (GetSecs - thisscenestart < scenedur)
            framePointer = Screen('GetMovieImage',w,moviepointers(m),0,[],[],1);
            if (framePointer>0)
                Screen('DrawTexture',w,framePointer,[],...
                    [cx-(.5*screenXadj),cy-(.5*screenYadj),cx+(.5*screenXadj),cy+(.5*screenYadj)]);
                Screen('Flip',w);
                Screen('Close',framePointer);
            end
        end
        Screen('PlayMovie', moviepointers(m), 0);
        
        % show importance rating instructions
        showRatingInstruction;
        scaleTime = Screen('Flip', w);
        
        % get importance rating 
        FlushEvents('keyDown');
        numstring = '0';
        
        while 1
            [keyIsDown, respTime, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(KEYENTER) == 1 % proceed to the next scene
                    
                    respNum = str2double(numstring);
                    
                    if ismember(respNum,1:10)
                        break;
                    end
                    
                elseif ismember(1,keyCode(KEYNUM)) % type number between 1~10
                    
                    if sum(keyCode) == 1
                        if numstring(end) ~= (num2str(find(find(keyCode)==KEYNUM)-1))
                            numstring = [numstring num2str(find(find(keyCode)==KEYNUM)-1)];
                        end
                        showRatingInstruction;
                        if length(numstring) == 1
                            centerTXT(numstring, 0, 60);
                        else
                            centerTXT(numstring(2:end), 0, 60);
                        end
                        Screen('Flip', w);
                    end
                    
                elseif keyCode(KEYDEL) == 1 % delete & correct the typed number
                    
                    numstring = '0';
                    showRatingInstruction;
                    Screen('Flip', w);
                end
            end
        end

        RT = respTime-scaleTime;
        
        % write data
        fprintf('SN:%2d movie:%2d scene:%3d resp:%2d RT:%4.4f\n',SN,m,scene,respNum,RT);
        fprintf(dataFile,'%2d,%2d,%3d,%2d,%4.4f\n',SN,m,scene,respNum,RT);

    end

    % end of movie
    movieEndTime = Screen('Flip',w);
    Screen('PlayMovie', moviepointers(m), 0);
    Screen('CloseMovie',moviepointers(m));
    
    fprintf('Movie %2d ended: elapsed time %4.2f\n\n', m, movieEndTime-movieStartTime);
end

% end of exp
pause(1);
ListenChar(0);
ShowCursor;
Screen('CloseAll');
fclose all;

return


function keySecs = pressThisKey(thiskeyCode)
% wait until a specific key is pressed,
% record the time it is pressed, and go the the next step

FlushEvents('keyDown');
while 1
    [keyIsDown, keySecs, keyCode] = KbCheck;
    if keyIsDown
        if (keyCode(thiskeyCode))
            break;
        end
    end
end

return

function centerTXT(msg, xoffset, yoffset)
% draw texts in the middle of the screen
% 'msg' in string, add offset values if you want...

global w cx cy textsize textcolor

Screen('TextSize', w, textsize);
Screen('TextColor', w, textcolor);
bounds = Screen('TextBounds', w, double(msg));
Screen('DrawText',w, double(msg), cx-bounds(3)/2+xoffset, cy+yoffset-bounds(4)/2);

return

function showRatingInstruction(varargin)

    centerTXT('How important is the movie segment that you have just watched?', 0, -70);
    centerTXT('Type a number between 1 (not important at all) ~ 10 (very important)', 0, -40);
    centerTXT('and press "p" to proceed to the next segment.', 0, -10);
    centerTXT('Press the delete key and retype the number if you need to change your response.', 0, 20);

return