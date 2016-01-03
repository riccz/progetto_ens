classdef RealTimeFilter < handle
    properties(GetAccess=private)
        x_buf
        y_buf
    end
    properties(SetAccess=private)
        filter
    end
    
    methods
        function obj = RealTimeFilter(filter)
            obj.filter = filter;
            obj.reset()
        end
        
        function reset(obj)
            obj.x_buf = zeros(1, obj.filter.order + 1);
            obj.y_buf = zeros(1, obj.filter.order + 1);
        end
        
        function y = next_sample(obj, x)
            obj.x_buf = circshift(obj.x_buf, 1, 2);
            obj.x_buf(1) = x;
            obj.y_buf = circshift(obj.y_buf, 1, 2);
            
            b = obj.filter.b;
            a = obj.filter.a;
            
            s1 = b .* obj.x_buf;
            s2 = -a .* obj.y_buf;
            obj.y_buf(1) = sum(s1) + sum(s2(2:length(s2)));
            y = obj.y_buf(1);
        end
    end
end
