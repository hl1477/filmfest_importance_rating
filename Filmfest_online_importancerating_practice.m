% Filmfest_online_importancerating_practice.m
% rating the subjective importance of each movie scene from the 10 filmfest
% movies while watching the movies for the first time (to be compared to
% the importance ratings collected "after" watching the movies)
% 4/8/2019 hongmi lee - practice movie (lobby)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  handling errors
function Filmfest_online_importancerating_practice(varargin)

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

% dataDir  = 'data'; 
% if ~exist(dataDir, 'dir') 
%     mkdir(dataDir)
% end
% 
% datafName = [dataDir '/' 'Filmfest_online_importance_' SN '_' NM '.csv'];
% dataFile  = fopen(datafName, 'a');

SN=str2double(SN); STARTMV=str2double(STARTMV); DEBUG=str2double(DEBUG); 

%% keyboard setup

KEYNUM  = [KbName('0)') KbName('1!') KbName('2@') KbName('3#') KbName('4$') ...
           KbName('5%') KbName('6^') KbName('7&') KbName('8*') KbName('9(')];
KEYENTER= KbName('p'); 
KEYDEL  = KbName('DELETE'); 
KEYGO   = KbName('space'); % go on (for subjects)

%% stimulus setup

nMovie = 1;
moviedir = [pwd '/stim'];
    moviefnames{1} = [moviedir '/FilmFest_lobby_practice.mp4'];

movobj = VideoReader(moviefnames{1});

% movie frame dimensions
height = movobj.Height;
width = movobj.Width;

% movie scene start times, first scene = 0 (title)
sceneStartTimes = {[0 11 17 23 29 34]};

% total duration of each movie in seconds
moviedur = [38]; 

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
%         fprintf(dataFile,'%2d,%2d,%3d,%2d,%4.4f\n',SN,m,scene,respNum,RT);

    end

    % end of movie
    movieEndTime = Screen('Flip',w);
    Screen('PlayMovie', moviepointers(m), 0);
    Screen('CloseMovie',moviepointers(m));
    
    fprintf('Movie %2d ended: elapsed time %4.2f\n\n', m, movieEndTime-movieStartTime);
end

% end of exp
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