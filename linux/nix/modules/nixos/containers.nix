{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
