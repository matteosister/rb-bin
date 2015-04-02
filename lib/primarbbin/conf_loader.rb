class YamlLoader
  def initialize(file_path)
    unless File.readable?(file_path)
      error 'Impossibile leggere il file'
    end
    @conf = YAML.load(File.read file_path)
  end

  def consumers
    @conf['old_sound_rabbit_mq']['consumers']
  end
end