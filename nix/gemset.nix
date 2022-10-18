{
  cardano-up = {
    dependencies = ["docopt" "file-tail" "httparty" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wysa71nqfkmrdwkcdlj1f94iynpa7rqxjyd5fcjdkbl14cpzcmp";
      type = "gem";
    };
    version = "0.1.2";
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
    dependencies = ["mime-types" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17gpnbf2a7xkvsy20jig3ljvx8hl5520rqm9pffj2jrliq1yi3w7";
      type = "gem";
    };
    version = "0.18.1";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ipw892jbksbxxcrlx9g5ljq60qx47pm24ywgfbyjskbcl78pkvb";
      type = "gem";
    };
    version = "3.4.1";
  };
  mime-types-data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "003gd7mcay800k2q4pb2zn8lwwgci4bhi42v2jvlidm8ksx03i6q";
      type = "gem";
    };
    version = "3.2022.0105";
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
      sha256 = "1kxykx7ywc0i3y4dwakz4b46dql4zc7h8b5w1hqhsqswq93s7i2i";
      type = "gem";
    };
    version = "1.31.1";
  };
}
