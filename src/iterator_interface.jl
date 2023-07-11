@inline function step!(integrator::ODEIntegrator)
    if integrator.opts.advance_to_tstop
        @inbounds while integrator.tdir * integrator.t < first(integrator.opts.tstops)
            loopheader!(integrator)
            (integrator.do_error_check && check_error!(integrator) != ReturnCode.Success) &&
                return
            perform_step!(integrator, integrator.cache)
            loopfooter!(integrator)
        end
    else
        @inbounds loopheader!(integrator)
        (integrator.do_error_check && check_error!(integrator) != ReturnCode.Success) &&
            return
        @inbounds perform_step!(integrator, integrator.cache)
        @inbounds loopfooter!(integrator)
        @inbounds while !integrator.accept_step
            dt = integrator.dt
            loopheader!(integrator)
            (integrator.do_error_check && check_error!(integrator) != ReturnCode.Success) &&
                return
            perform_step!(integrator, integrator.cache)
            loopfooter!(integrator)
            if integrator.dt <= integrator.opts.dtmin && dt <= integrator.opts.dtmin
                error("Integrator looped. No progress")
            end
        end
    end
    @inbounds handle_tstop!(integrator)
end
