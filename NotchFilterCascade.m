classdef NotchFilterCascade < handle
    properties
        q
        f_0
        enabled
    end
    properties(Dependent)
        b
        a
        order
    end
    properties(GetAccess=private)
        coeffs_valid
        b_cache
        a_cache
    end
    properties(SetAccess=private)
        num_filters
        Fs
    end
    
    methods
        function obj = NotchFilterCascade(num_filters, Fs)
            obj.Fs = Fs;
            obj.q = 1;
            obj.f_0 = zeros(1, num_filters);
            obj.enabled = zeros(1, num_filters);
            obj.coeffs_valid = false;
            obj.num_filters = num_filters;
        end
        
        function order = get.order(obj)
            order = obj.num_filters * 2;
        end
        
        function b = get.b(obj)
            if ~obj.coeffs_valid
                obj.update_coeffs;
            end
            b = obj.b_cache;
        end
        
        function a = get.a(obj)
            if ~obj.coeffs_valid
                obj.update_coeffs;
            end
            a = obj.a_cache;
        end
        
        function set.f_0(obj, f_0)
            obj.coeffs_valid = false;
            obj.f_0 = f_0;
        end
        
        function set.q(obj, q)
            obj.coeffs_valid = false;
            obj.q = q;
        end
        
        function set.enabled(obj, enabled)
            obj.coeffs_valid = false;
            obj.enabled = enabled;
        end
        
        function update_coeffs(obj)
            b_prod = 1;
            a_prod = 1;
            for i = 1:obj.num_filters
                if obj.enabled(i)
                    [b, a] = notch_filter(obj.f_0(i), obj.Fs, obj.q);
                    b_prod = conv(b_prod, b);
                    a_prod = conv(a_prod, a);
                end
            end
            if a_prod(1) ~= 1
                b_prod = b_prod ./ a_prod(1);
                a_prod = a_prod ./ a_prod(1);
            end
            obj.b_cache = padarray(b_prod, [0, obj.order + 1 - length(b_prod)], 'post');
            obj.a_cache = padarray(a_prod, [0, obj.order + 1 - length(a_prod)], 'post');
            obj.coeffs_valid = true;
        end
    end
end
