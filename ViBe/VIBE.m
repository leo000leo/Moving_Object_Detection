classdef VIBE < handle  
    % VIBE.m  
    % -------------------------------------------------------------------  
    % Reference: BackgroundSubtractorMOG2.m  
    % Authors: LSS  
    % Date:    27/04/2017  
    % Last modified: 28/04/2017  
    % -------------------------------------------------------------------  
      
    properties (SetAccess = private)  
        id % Object ID  
    end  
      
    methods  
        function this = VIBE()  
            this.id = VIBE_(0, 'new');  
        end  
          
        function delete(this)  
            %DELETE  Destructor  
            %  
            VIBE_(this.id, 'delete');  
        end  
          
        function fgmask = GetfrImageC3R(this, im)  
            %  
            fgmask = VIBE_(this.id, 'GetfrImageC3R', im);  
        end  
    end  
      
end  