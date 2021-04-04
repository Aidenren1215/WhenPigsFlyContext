clc;

NumApts = 7;
NumRooms = 4;
NumThres = 7; %must be in all 7 rooms
PixToVA = 156/5; %pixels per visual angle in degrees

T = readtable('Mat/jason_2_combined.csv');
classlist = string(T{1:2:end,1});
apartmentlist = T{1:2:end,2};
roomlist = string(T{1:2:end,3});
surfacelist = string(T{1:2:end,4});

imagelist = string(T{1:2:end,5});
leftlist = T{2:2:end,1};
leftlist = cellfun(@str2num,leftlist);

toplist = T{2:2:end,2};
%toplist = cellfun(@str2num,toplist);

rightlist = T{2:2:end,3};
rightlist = cellfun(@str2num,rightlist);

bottomlist = T{2:2:end,4};
bottomlist = cellfun(@str2num,bottomlist);

UniqueRoomList = unique(roomlist);
UniqueSurfaceList = unique(surfacelist);

classAll = unique(classlist);
display(length(classAll));
filtered_class = {};


for classid = 1:length(classAll)
    
    classname = classAll{classid};
    %display(classname);
    whereapt = unique(apartmentlist(find(classlist == classname)));
    if length(whereapt) >= NumThres
        filtered_class = [filtered_class classname];
    else
        display(classname);
    end
    
end

countAll = zeros(length(filtered_class), NumApts, NumRooms);
VHhumanStats = [];

for classid = 1:length(filtered_class) 
    
    classname = filtered_class{classid};
    
    whereimg = imagelist(find(classlist == classname));
    whereapt = apartmentlist(find(classlist == classname)) + 1;
    if length(unique(whereapt)) < NumThres
        error(['we should not be here']);
    end
    
    wheresurface = surfacelist(find(classlist == classname));
    whereroom = roomlist(find(classlist == classname));
    whereleft = leftlist(find(classlist == classname));
    whereright = rightlist(find(classlist == classname));
    wheretop = toplist(find(classlist == classname));
    wherebottom = bottomlist(find(classlist == classname));
    
    for i= 1:length(whereapt)
        ind_apt = whereapt(i);
        [ind_room temp] = find(whereroom(i) == UniqueRoomList);
        countAll(classid, ind_apt, ind_room) = countAll(classid, ind_apt, ind_room) + 1;
        view = squeeze(countAll(classid,:,:));
        imgname = whereimg(i);
        surfacename = wheresurface(i);
        surfaceid = find(wheresurface(i) == UniqueSurfaceList);
        infor.classname = classname;
        infor.classid = classid;
        infor.whereapt = ind_apt;
        infor.whereroom = whereroom(i);
        infor.wheresurface = surfacename;
        infor.surfaceid = surfaceid;
        infor.roomid = ind_room;
        infor.imgname = strtrim(imgname);
        infor.left = whereleft(i);
        infor.right = whereright(i);
        infor.top = wheretop(i);
        infor.bottom = wherebottom(i);
        
        area = (infor.right - infor.left) * ( infor.bottom - infor.top);
        dva = sqrt(area)/PixToVA;
        infor.dva = dva;
        
        VHhumanStats = [VHhumanStats infor];
        
    end
    
    %view = squeeze(countAll(classid,:,:));
    display(view);
end

save('Mat/VHhumanStats.mat','VHhumanStats','countAll','UniqueRoomList','filtered_class','UniqueSurfaceList');


