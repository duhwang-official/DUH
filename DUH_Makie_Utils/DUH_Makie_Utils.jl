module DUH_Makie_Utils

    using Makie

    """
        function drawGL(fig)
        * fig::Figure 를 GLMakie로 열어줌. 열고 난 이후에 다시 원래 backend로 귀환.
        function drawGL()
        * 방금 전에 그린(current_figure()) 그림을 GLMakie로 보여줌.
    """
    function drawGL(fig::Union{Figure,Makie.FigureAxisPlot})

        if isdefined(Main,:GLMakie)
            current = Makie.current_backend()
            GLMakie.activate!()
            display(fig)
            @info "Figure is drawn in GL window.."
            current.activate!()
        else
            error("GLMakie is not loaded..")
        end
    end
    drawGL(::Nothing) = error("No figure exists..")
    drawGL() = drawGL(current_figure())

    hello() = @info "Hello"

    ## 아래 함수는 x축이 날짜인 경우 문제를 해결하기 위한 함수 집합임.


    using Dates

    function gen_date_ticks_fun(n_ticks::Int, format::String="auto")

        n_ticks > 0 || error("date_ticks: n_ticks must be positive!")

        return function(vmin, vmax)

            ( vmin isa Date || vmin isa DateTime ) && error("f(vmin,vmax): vmin, vmax should be integer")

            ( typeof(vmin) <: AbstractFloat ) && ( vmin = Integer.(round.(vmin)) )
            ( typeof(vmax) <: AbstractFloat ) && ( vmax = Integer.(round.(vmax)) )

            dt_min = Dates.epochdays2date(vmin)
            dt_max = Dates.epochdays2date(vmax)

            time_span = dt_max - dt_min

            interval, date_format = choose_interval_and_format(time_span, n_ticks,format)

            tick_dates = generate_ticks(dt_min, dt_max, interval)

            tick_position = Float64[Dates.date2epochdays(dt) for dt in tick_dates]

            tick_labels = String[Dates.format(dt,date_format) for dt in tick_dates]

            return (tick_position, tick_labels)
        end

    end

    function choose_interval_and_format(time_span::Period, n_ticks::Int, user_format::String)

        total_days = Dates.value(time_span)

        if user_format != "auto"
            interval = estimate_interval(time_span, n_ticks)
            return (interval, user_format)
        end

        if total_days < 365
            interval = Day( max( 1, round( Int, total_days/ n_ticks )))
            format = "yyyy-mm-dd"
        elseif total_days < 365*3
            interval = Month( max( 1, round( Int, total_days/ 30 / n_ticks )))
            format = "yyyy-mm"
        else
            interval = Year( max( 1, round(Int, total_days/ 365/ n_ticks )))
            format = "yyyy"
        end

        return (interval, format)

    end

    function estimate_interval(time_span::Period, n_ticks::Int)
        
        total_days = Dates.value(time_span)
        interval_days = total_days / n_ticks

        if interval_days < 30 # 30일 미만..
            return Day(max(1, round(Int, interval_days)))
        else
            return Month(max(1, round(Int, interval_days/30)))
        end

    end

    function generate_ticks(dt_min::Date, dt_max::Date, interval::Period)

        first_tick = round_date(dt_min, interval)

        ticks = Date[]
        current = first_tick

        if current < dt_min
            current = current + interval 
        end

        while current <= dt_max
            push!(ticks, current)
            current = current + interval 
        end

        if isempty(ticks)
            push!(ticks, dt_min, dt_max)
        elseif length(ticks) == 1
            push!(ticks, dt_max)
        end

        return ticks

    end

    """
        function round_date(dt::Date, interval::Period) -> Date
    """
    function round_date(dt::Date, interval::Period)

        if interval isa Year
            return Date( year( dt), 1, 1 )
        elseif interval isa Month
            return Date( year( dt), month( dt), 1 )
        elseif interval isa Day
            return Date( year( dt), month( dt), day(dt) )
        else
            return dt
        end
    end


    ## for simple drawing
    export makie_default, makie_size
    
    makie_default = (; xlabel="time", ylabel="value", title="Plot"  )
    makie_size = (1400,400)

    #=
    using PlotUtils: optimize_ticks

    # 아래 함수는 날짜를 숫자로, 숫자를 날짜(문자)로 변환하는 함수임
    # 숫자가 정수가 아닌경우, 날짜가 아닌 날짜+시간 형태로 다시 계산해서 
    # 문자열 형태로 반환함.
    function _val2_datetick(x)
        if isinteger(x)
            return "$(Date(Dates.UTD(x)))"
        else
            return "$(DateTime(Dates.UTM(x*24*3600000)))"
        end
    end

    _date2val(x::Date) =  Dates.value(x)
    =#

    function simple_line(xdata::Vector,ydata::Vector; plot_fun=lines! , size=makie_size , opts...  )
        
        f = Figure(; size=size )
        if @isdefined makie_default
            ax = Axis(f[1,1]; makie_default..., opts...  )
        else
            ax = Axis(f[1,1]; opts... )
        end
        p=plot_fun(ax, xdata , ydata )

        #display(f)
        return f,ax,p
    end

    using DataFrames

    function df_simple_line(df::DataFrame, xsym::Symbol, ysym::Symbol ; plot_fun=lines!, size=makie_size , opts... )
        df_simple_line(df,xsym,[ysym]; plot_fun=plot_fun, size=size , opts... )
    end

    function df_simple_line(df::DataFrame, xsym::Symbol, ysymvec::Vector{Symbol} ; plot_fun=lines!, size=makie_size, opts... )
        f = Figure(;size=size)
        if @isdefined makie_default
            ax = Axis(f[1,1]; makie_default..., opts...)
        else
            ax = Axis(f[1,1]; opts... )
        end

        for line_sym in ysymvec

            p=plot_fun(ax, df[!,xsym], df[!,line_sym] )
            
        end
        
        #display(f)
        
        return f

    end 

    #@info "simple_line, df_simple_line is defined..."

end   # end of modula definition
