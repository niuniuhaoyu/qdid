*! qdid: Quantile Treatment Effects in Difference-in-Differences
*! version 0.0.1  2026-10-06  Haoyu Niu
*! Skeleton (Task 1). See docs/specs/2026-10-06-qdid-design.md and
*! docs/plans/2026-10-06-qdid-plan.md for the implementation plan.

program define qdid, rclass
    version 16

    syntax varlist(max=1 numeric) [if] [in], ///
        unit(varname numeric) ///            individual id
        time(varname numeric) ///            time period (two periods)
        treat(varname numeric) ///           binary treatment indicator
        quantiles(numlist) ///               quantiles at which to estimate QTT
        [covariates(varlist) ///             covariates (conditional parallel trends)
         level(real 95) ///                  confidence level (%)
         seed(integer 12345) ///             RNG seed (bootstrap)
         reps(integer 999) ///               bootstrap replications
         cluster(varname) ///                cluster variable (default = unit)
         cband ///                            uniform confidence band (sup-t)
         GRaph]                               // QTT(q) plot

    di as error "qdid: not yet implemented (skeleton). See docs/plans/2026-10-06-qdid-plan.md"
    exit 199
end
