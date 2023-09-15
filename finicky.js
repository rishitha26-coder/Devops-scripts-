module.exports = {
  defaultBrowser: "/Applications/Browserosaurus.app",
  //rewrite: [
    //{
      // Redirect all urls to use https
      //match: ({ url }) => url.protocol === "http",
      //url: { protocol: "https" }
    //}
  //],
  handlers: [
    {
      // Open apple.com and example.org urls in Safari
      match: ["mogo.awsapps.com/*", "login.microsoftonline.com/*", "*.mogo.ca/*", "mogo.*/*", "mogofintech.*/*", "*.atlassian.net/*", "slack.com/openid/*", "*github*"],
      browser: { name: "Google Chrome",
      profile: "Profile 1" }
    },
    {
      // Open apple.com and example.org urls in Safari
      match: ["*.awsapps.com/*", "*.amazonaws.com/*", "*.apple.com/*"],
      browser: "Safari"
    },
    {
      // Open any url that includes the string "workplace" in Firefox
      match: /workplace/,
      browser: "Firefox"
    },
    {
      // Open google.com and *.google.com urls in Google Chrome
      match: [
        "google.com/*", // match google.com urls
        "*.google.com/*", // match google.com subdomains
      ],
      browser: "Google Chrome"
    }
  ]
};
