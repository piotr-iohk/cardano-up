{
  cardano-up = {
    dependencies = ["docopt" "file-tail" "httparty" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13p3d9jw8v5h9msdigwraf3v79ifnrbvd33xnq9l7vi220lxirps";
      type = "gem";
    };
    version = "0.1.3";
  };
  docopt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rvlfbb7kzyagncm4zdpcjwrh682zamgf5rcf5qmj0bd6znkgy3k";
      type = "gem";
    };
    version = "0.6.1";
  };
  file-tail = {
    dependencies = ["tins"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1na3ddmsd30i08a04h9n85amnvnrx8v7cvphi55pb7009jk6qbqm";
      type = "gem";
    };
    version = "1.2.0";
  };
  httparty = {
    dependencies = ["mini_mime" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "050jzsa6fbfvy2rldhk7mf1sigildaqvbplfz2zs6c0zlzwppvq0";
      type = "gem";
    };
    version = "0.21.0";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  multi_xml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lmd4f401mvravi1i1yq7b2qjjli0yq7dfc4p1nj5nwajp7r6hyj";
      type = "gem";
    };
    version = "0.6.0";
  };
  rubyzip = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      type = "gem";
    };
    version = "2.3.2";
  };
  sync = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z9qlq4icyiv3hz1znvsq1wz2ccqjb1zwd6gkvnwg6n50z65d0v6";
      type = "gem";
    };
    version = "0.5.0";
  };
  tins = {
    dependencies = ["sync"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0373zn7zkllcn2q4ylbjgjx9mvm8m73ll3jwjav48dx8myplsp5p";
      type = "gem";
    };
    version = "1.32.1";
  };
}
