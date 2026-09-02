{
  sops = {
    defaultSopsFile = ../../secrets.yaml;

    secrets.nas = {
      path = "/home/mk/.ssh/nas";
      owner = "mk";
      group = "users";
      mode = "0600";
    };

    secrets.nas_pub = {
      path = "/home/mk/.ssh/nas.pub";
      owner = "mk";
      group = "users";
      mode = "0644";
    };

    secrets.ssh_config = {
      path = "/home/mk/.ssh/config";
      owner = "mk";
      group = "users";
      mode = "0600";
    };
  };
}
