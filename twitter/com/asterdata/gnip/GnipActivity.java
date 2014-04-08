package com.asterdata.gnip;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;

import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.map.ObjectMapper;

import com.asterdata.util.TextLib;


@JsonIgnoreProperties(ignoreUnknown = true)
public class GnipActivity {
	private static final ObjectMapper mapper = new ObjectMapper();
	private static final String DELIMITER="|";
	
	private String id;
	private InReplyTo inReplyTo;
	private String body;
	private Location location;
	private String verb;
	private String link;
	private String postedTime;
	private Object object;
	private Actor actor;
	private String objectType;
	private Gnip gnip;
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
	
	public InReplyTo getInReplyTo() {
		return inReplyTo;
	}

	public void setInReplyTo(InReplyTo inReplyTo) {
		this.inReplyTo = inReplyTo;
	}
	
	public boolean isReplyTweet() {
		return inReplyTo == null ? false: true;
	}

	public long getTweetId() {
		int indx = id.lastIndexOf(":")+1;
		return Long.parseLong(id.substring(indx));
	}

	public String getBody() {
		return body;
	}

	public void setBody(String body) {
		this.body = body;
	}
	
	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}

	public boolean isRetweet() {
		if(object != null && body.startsWith("RT @")) {
			return true;
		}
		
		return false;
	}

	public String getVerb() {
		return verb;
	}

	public void setVerb(String verb) {
		this.verb = verb;
	}

	public String getLink() {
		return link;
	}

	public void setLink(String link) {
		this.link = link;
	}
	
	public String getPostedTime() {
		return postedTime;
	}

	public void setPostedTime(String postedTime) {
		this.postedTime = postedTime;
	}

	public Object getObject() {
		return object;
	}

	public void setObject(Object object) {
		this.object = object;
	}

	public Actor getActor() {
		return actor;
	}

	public void setActor(Actor actor) {
		this.actor = actor;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Gnip getGnip() {
		return gnip;
	}

	public void setGnip(Gnip gnip) {
		this.gnip = gnip;
	}
	
	/**
	 * Factory method that parses Gnip Twitter activity document into GnipActivity object
	 */	
	public static final GnipActivity parseJSON(String activityJson) throws Exception {
		JsonNode rootNode = mapper.readTree(TextLib.normalize(activityJson));
		GnipActivity data = mapper.treeToValue(rootNode, GnipActivity.class);
		return data;
	}
	
	/**
	 * Parses GnipActivity into twitter related record that can be used in sentiment analysis.
	 * 
	 * Output Record layout is following
	 * 
	 * tweetId  			- tweet message status id
	 * postedTime			- time the tweet was posted
	 * tweetTxt				- tweet text
	 * isRetweet			- true/false if tweet is a retweet of original content
	 * userId				- twitter user id of the person who has tweeted
	 * userName				- twitter user name
	 * screenName			- twitter user screen name
	 * followerCount		- twitter user follower count for the user
	 * friendsCount			- twitter user friends count
	 * userLocation			- location of the user as he/she provided in twitter registration page
	 * inReplyStatusId		- status id of the original tweet that the user is replying to
	 * inReplyTo			- User name that the tweet is replied to
	 * retweetOrigTweetId 	- Original content tweet Id (this is only available for retweeted tweets)
	 * retweetOrigUserId	- Original user Id who posted the tweet that was retweeted (this is only available if it is a retweet)
	 * language				- language
	 * kloutScore			- Klout score
	 * 
	 * @param delimiter
	 * @return
	 * @throws GnipJsonParsingException
	 */
	public String extractGnipTwitterData(String delimiter) throws GnipJsonParsingException {
		if(id == null)
			throw new GnipJsonParsingException("Incorectly formatted gnip JSON doc, missing expected \"id\" element");
		

		StringBuilder sb = new StringBuilder();
		
		sb.append(getTweetId()).append(delimiter);
		sb.append(postedTime).append(delimiter);
		sb.append(body).append(delimiter);
		sb.append(isRetweet()).append(delimiter);
		sb.append(actor.getUserId()).append(delimiter);
		sb.append(actor.getDisplayName()).append(delimiter);
		sb.append(actor.getPreferredUsername()).append(delimiter);
		sb.append(actor.getFollowersCount()).append(delimiter);
		sb.append(actor.getFriendsCount()).append(delimiter);
		
		if(actor.getLocation() != null) {
			sb.append(actor.getLocation().getDisplayName());
		}
		
		sb.append(delimiter);
		
		if(inReplyTo != null) {
			sb.append(inReplyTo.getStatusId());
		}
		
		sb.append(delimiter);
		
		//TODO: some retweets are missing the original content
		if(isRetweet() && object.getObject() != null) {
			sb.append(object.getTweetId()).append(delimiter).append(object.getActor().getUserId());
		} else {
			sb.append(delimiter);
		}
		
		sb.append(delimiter);
		if (gnip.getLanguage() != null) {
			sb.append(gnip.getLanguage().getValue());
		}
		sb.append(delimiter);
		sb.append(gnip.getKlout_score());
		return sb.toString();
	}
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class InReplyTo {
		private String link;

		public String getLink() {
			return link;
		}

		public void setLink(String link) {
			this.link = link;
		}
		
		public String getUserName() {
			//http://twitter.com/empireofthekop/statuses/24234534
			int indx = link.indexOf("twitter.com/")+12;
			return link.substring(indx, link.indexOf("/", indx));
		}
		
		public long getStatusId() {
			int indx = link.lastIndexOf("/")+1;
			return Long.parseLong(link.substring(indx));
		}
		
	}
	
	/**
	 * Extended info on tweet or original tweet if the GnipActivity is of retweet type.
	 * 
	 * @author mmichalski
	 */
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class Object {
		private String summary;
		private String id;
		private String postedTime;
		private Object object;
		private Actor actor;
		private String objectType;
		
		public String getSummary() {
			return summary;
		}

		public void setSummary(String summary) {
			this.summary = summary;
		}

		public String getId() {
			return id;
		}

		public void setId(String id) {
			this.id = id;
		}
		
		public long getTweetId() {
			int indx = id.lastIndexOf(":")+1;
			return Long.parseLong(id.substring(indx));
		}

		public String getPostedTime() {
			return postedTime;
		}
		
		public void setPostedTime(String postedTime) {
			this.postedTime = postedTime;
		}
		
		public Object getObject() {
			return object;
		}
		
		public void setObject(Object object) {
			this.object = object;
		}
		
		public Actor getActor() {
			return actor;
		}
		
		public void setActor(Actor actor) {
			this.actor = actor;
		}
		
		public String getObjectType() {
			return objectType;
		}
		
		public void setObjectType(String objectType) {
			this.objectType = objectType;
		}
	}
	
	
	/**
	 * Represents the user who tweeted or the original user of the tweet in case of retweet event
	 * 
	 * @author mmichalski
	 */
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class Actor {
		private String summary;
		private String twitterTimeZone;
		private int friendsCount;
		private Location location;
		private int listedCount;
		private String id;
		private String[] languages;
		private int utcOffset;
		private int followersCount;
		private int statusesCount;
		private String preferredUsername;
		private String displayName;
		
		public String getSummary() {
			return summary;
		}
		
		public void setSummary(String summary) {
			this.summary = summary;
		}
		
		public String getTwitterTimeZone() {
			return twitterTimeZone;
		}
		
		public void setTwitterTimeZone(String twitterTimeZone) {
			this.twitterTimeZone = twitterTimeZone;
		}
		
		public int getFriendsCount() {
			return friendsCount;
		}
		
		public void setFriendsCount(int friendsCount) {
			this.friendsCount = friendsCount;
		}
		
		public Location getLocation() {
			return location;
		}
		
		public void setLocation(Location location) {
			this.location = location;
		}
		
		public int getListedCount() {
			return listedCount;
		}
		
		public void setListedCount(int listedCount) {
			this.listedCount = listedCount;
		}
		
		public String getId() {
			return id;
		}
		
		public void setId(String id) {
			this.id = id;
		}
		
		public long getUserId() {
			int indx = id.lastIndexOf(":")+1;
			
			return Long.parseLong(id.substring(indx));
		}
		
		public String[] getLanguages() {
			return languages;
		}
		
		public void setLanguages(String[] languages) {
			this.languages = languages;
		}
		
		public int getUtcOffset() {
			return utcOffset;
		}
		
		public void setUtcOffset(int utcOffset) {
			this.utcOffset = utcOffset;
		}
		
		public int getFollowersCount() {
			return followersCount;
		}
		
		public void setFollowersCount(int followersCount) {
			this.followersCount = followersCount;
		}
		
		public int getStatusesCount() {
			return statusesCount;
		}

		public void setStatusesCount(int statusesCount) {
			this.statusesCount = statusesCount;
		}

		public String getPreferredUsername() {
			return preferredUsername;
		}
		
		public void setPreferredUsername(String preferredUsername) {
			this.preferredUsername = preferredUsername;
		}
		
		public String getDisplayName() {
			return displayName;
		}
		
		public void setDisplayName(String displayName) {
			this.displayName = displayName;
		}
	}
	
	
	/**
	 *  Location infomration of the user who tweeted/retweeted. 
 	 * 
	 * @author mmichalski
	 */
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class Location {
		private String displayName;
		private String country_code;
		private String objectType;
		private Geo geo;
		private String name;
		
		
		public Geo getGeo() {
			return geo;
		}

		public void setGeo(Geo geo) {
			this.geo = geo;
		}
		
		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public String getDisplayName() {
			return displayName;
		}

		public void setDispalyName(String displayName) {
			this.displayName = displayName;
		}

		public String getCountry_code() {
			return country_code;
		}

		public void setCountry_code(String country_code) {
			this.country_code = country_code;
		}

		public String getObjectType() {
			return objectType;
		}

		public void setObjectType(String objectType) {
			this.objectType = objectType;
		}
	}
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class Geo {
		private String type;
		private String[][][] coordinates;
		
		public String getType() {
			return type;
		}
		
		public void setType(String type) {
			this.type = type;
		}
		
		public String[][][] getCoordinates() {
			return coordinates;
		}
		
		public void setCoordinates(String[][][] coordinates) {
			this.coordinates = coordinates;
		}
		
	}
	
	/**
	 * Gnip specific information about the activity 
	 * 
	 * @author mmichalski
	 */
	
	@JsonIgnoreProperties(ignoreUnknown = true)
	public static class Gnip {
		private Language language;
		private int klout_score;
		private Url[] urls;
		
		public Language getLanguage() {
			return language;
		}

		public void setLanguage(Language language) {
			this.language = language;
		}

		public int getKlout_score() {
			return klout_score;
		}

		public void setKlout_score(int klout_score) {
			this.klout_score = klout_score;
		}
		
		public Url[] getUrls() {
			return urls;
		}

		public void setUrls(Url[] urls) {
			this.urls = urls;
		}

		@JsonIgnoreProperties(ignoreUnknown = true)
		public static class Language {
			private String value;

			public String getValue() {
				return value;
			}

			public void setValue(String value) {
				this.value = value;
			}
		}
		
		@JsonIgnoreProperties(ignoreUnknown = true)
		public static class Url {
			private String url;
			private String expanded_url;
			
			public String getUrl() {
				return url;
			}
			
			public void setUrl(String url) {
				this.url = url;
			}
			
			public String getExpanded_url() {
				return expanded_url;
			}
			
			public void setExpanded_url(String expanded_url) {
				this.expanded_url = expanded_url;
			}
			
		}
	}
	
	public static void main(String[] args) throws FileNotFoundException, UnsupportedEncodingException {
		if(args.length<1) {
			System.out.println("Usage: GnipActivity [-d] INPUT_FILE");
			System.exit(-1);
		}
		boolean debug = false;
		String inputFile = "";
		if (args[0].equals("-d")) {
			debug = true;
			inputFile = args[1];
		} else {
			inputFile = args[0];
		}
		
		BufferedReader br = null;
		int lineCount = 0;
		int parseErrorCount = 0;
		try {
			br = new BufferedReader(new InputStreamReader(new FileInputStream(inputFile), "UTF8"));
			String jsonDoc = null;
			GnipActivity activity = null;
			while((jsonDoc= br.readLine()) != null) {
				jsonDoc = TextLib.normalize(jsonDoc);
				lineCount++;
				if (debug) {
					System.out.println(jsonDoc);
				} else {
					try {
						activity = GnipActivity.parseJSON(jsonDoc);
					} catch (Exception e) {
						parseErrorCount++;
						System.err.println("Parsing error [" + e.getMessage() + "] while processing line #" + lineCount + " (" + 
								parseErrorCount + " so far) with content:");
						System.err.println(jsonDoc);
					}
					if (activity != null)
						System.out.println(activity.extractGnipTwitterData(DELIMITER));
				}
			}	
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				br.close();
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
}
