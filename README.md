# IMPACT-ablation
Analysis routines for luminous efficiency experiments using the CU-LASP IMPACT facility

To process data:

1.) Run check_dust_data, or otherwise identify triggers which have an ablation event

2.) Run process_flagged_events; this isolates data for ablation events. Individual events can then be visualized using plot_event

3.) Identify events in metadata: routines match_metadata, extract_particle_metadata, and extract_timestamp help calculate the trigger timestamp for each event, which can then be matched to the particle mass & velocity from the accelerator

4.) Run process_daily_data to calculate tau for a days worth of data (key routine: lum_eff_calc). Produces an array with the particle mass, velocity, and luminous efficiency

5.) Combine all outputs. You can use plot_daily to do this but I wouldn't recommend it

6.) tau_plots plots luminous efficiency against velocity and mass, with errors and fits
