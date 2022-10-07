module CardanoUp
  module Tail
    def self.tail(file_path)
      File.open(file_path) do |log|
        log.extend(File::Tail)
        log.interval
        log.backward(10)
        log.tail { |line| STDERR.puts line }
      end
    end
  end
end
