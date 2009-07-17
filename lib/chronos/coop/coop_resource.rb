class Coop
  # This is the base class from which all resource
  # classes for Coop inherit. Site and authentication params
  # are loaded into this class when a Harvest::Base
  # object is initialized.
  class Resource < ActiveResource::Base

  end
end