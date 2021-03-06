function schema
%SCHEMA class definition for polarscatter
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGraphics package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define polarscatter class, use hggroup as baseclass
h = schema.class(pkg,'polarscatter',pkgHG.findclass('hggroup'));
h.Description = 'Polar scatter plot';

%initialize variables
l = []; %will hold listeners
markDirtyProp = []; %will hold properties


%-------DEFINE PROPERTIES-------

%angle units property
p = schema.prop(h,'AngleUnits','AngleUnitsType'); %#ok
p.Description='Angular units used (radians or degrees)';
p.FactoryValue='radians';

%angle data property
p=schema.prop(h,'AngleData','MATLAB array');
p.Description='Angular data';
p.FactoryValue=2*pi*rand(20,1);
markDirtyProp = Lappend(markDirtyProp,p);

%radius data property
p=schema.prop(h,'RadiusData', 'MATLAB array');
p.Description='Radial data';
p.FactoryValue=0.8*rand(20,1)+0.2;
markDirtyProp = Lappend(markDirtyProp,p);

%angle data clipping method property
p=schema.prop(h,'AngleClip', 'AngleClipType');
p.Description = 'Clipping mode for angles';
p.FactoryValue='nan';
markDirtyProp = Lappend(markDirtyProp,p);

%radius data clipping method property
p=schema.prop(h,'RadiusClip','RadiusClipType');
p.Description = 'Clipping mode for radii';
p.FactoryValue='nan';
markDirtyProp = Lappend(markDirtyProp,p);

%size data
p=schema.prop(h,'SizeData','MATLAB array');
p.Description='Marker size data';
p.FactoryValue=25+5*rand(20,1);
markDirtyProp = Lappend(markDirtyProp,p);

%color data
p=schema.prop(h,'ColorData', 'MATLAB array');
p.Description='Marker color data';
p.FactoryValue=jet(20);
markDirtyProp = Lappend(markDirtyProp,p);

%line width
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description='Marker line width';
p.FactoryValue = 1;

%marker style 
p=schema.prop(h,'Marker','lineMarkerType'); %#ok
p.Description='Marker style';
p.FactoryValue='o';

%marker edge color
p=schema.prop(h,'MarkerEdgeColor','patchMarkerEdgeColorType'); %#ok
p.Description='Marker edge color';
p.FactoryValue='flat';

%marker face color
p=schema.prop(h,'MarkerFaceColor','patchMarkerFaceColorType'); %#ok
p.Description='Marker face color';
p.FactoryValue='flat';

%handle of scatter plot
p=schema.prop(h,'hScatter', 'handle vector'); %#ok
p.Description='Handle of scatter object';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles of property listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

%initialization flag property
p = schema.prop(h, 'Initialized', 'double'); %#ok
p.Description='Initialization flag';
p.FactoryValue = 0;
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

%dirty flag property
p = schema.prop(h, 'Dirty', 'DirtyEnum');
p.Description='Whether polar area needs refresh';
p.FactoryValue = 'invalid';
p.Visible = 'off';
 
%refresh mode property
p2 = schema.prop(h, 'RefreshMode', 'axesXLimModeType');
p2.Description='Auto/manual refresh mode';
p2.FactoryValue = 'manual';
p2.Visible = 'off';

%create listeners for triggering a refresh
%always put dirty listener first in list
l = Lappend(l,handle.listener(h, [p p2], 'PropertyPostSet', @LdoDirtyAction));

%create listeners for the properties that should set the dirty flag
l = Lappend(l,handle.listener(h,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));

%store listeners in the root object application data
setappdata(0,'PolarScatterListeners',l);


%-------SUBFUNCTIONS-------

function out = Lappend(in,data)
%LAPPEND helper function
if isempty(in)
  out = data;
else
  out = [in data];
end


function LdoMarkDirtyAction(hSrc, eventData) %#ok
%LDOMARKDIRTYACTION set dirty flag
h = eventData.affectedObject;
if h.initialized
  h.dirty = 'invalid';
end
 
function LdoDirtyAction(hSrc, eventData) %#ok
%LDODIRTYACTION trigger refresh
h = eventData.affectedObject;
if h.initialized && strcmp(h.refreshmode,'auto')
  refresh(h);
end
