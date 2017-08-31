use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"N<AR7k_iHUnLR?6l3Cij2*bbZgMtgBqH(Tk>]:pA1exy($TYV[kF*}=PTMR*6Nf$"
end

# no :heroku environment needed because we don't use distillery there.
environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"t7:P5P|$c)woML.V0`gY.>)6vOqrm}S_H<J[i~$)7D{=f1difrmV^)8c,LCxbymD"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :course_planner do
  set version: current_version(:course_planner)
end

