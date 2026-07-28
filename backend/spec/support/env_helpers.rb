module EnvHelpers
  def with_env(vars)
    original = vars.each_key.to_h { |k| [k, ENV[k]] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    original.each { |k, v| ENV[k] = v }
  end
end
