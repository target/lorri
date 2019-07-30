{ stableVersion }:
{
  nightly = {
    channel = "nightly";
    date = "2019-06-13";
  };
  stable = {
    channel = stableVersion;
  };
}
