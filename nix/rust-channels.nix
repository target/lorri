{ stableVersion }:
{
  nightly = {
    channel = "nightly";
    date = "2019-10-11";
  };
  stable = {
    channel = stableVersion;
  };
}
