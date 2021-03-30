# a simple global diagnostic context for error notification (as well as logging, later)
#  NOTE: not dealing with thread safety as Unicorn / Resque are not multi-threaded
class PioDiagnostics
  def self.context
    @context ||= {}
  end

  def self.clear_context!
    @context = {}
  end
end
