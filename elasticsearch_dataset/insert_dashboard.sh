#!/bin/bash

## Create the twitter index pattern
curl -XPOST 'localhost:9200/_bulk?pretty' -H 'Content-Type: application/json' -d '
{ "index" : { "_index" : ".kibana", "_type" : "config", "_id" : "'$1'" } }
{ "buildNum": '$2', "defaultIndex": "twitter" }
'

## Set the default index to twitter
curl -XPOST 'localhost:9200/_bulk?pretty' -H 'Content-Type: application/json' -d '
{ "index" : { "_index" : ".kibana", "_type" : "index-pattern", "_id" : "twitter" } }
{ "title":"twitter","customFormats":"{}","fields":"[{\"type\":\"string\",\"indexed\":false,\"analyzed\":false,\"name\":\"_index\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"name\":\"_type\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":false,\"analyzed\":false,\"name\":\"_source\",\"count\":0,\"scripted\":false},{\"type\":\"geo_point\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"location\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":false,\"analyzed\":false,\"name\":\"_id\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":true,\"doc_values\":false,\"name\":\"sentiment\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":true,\"doc_values\":false,\"name\":\"hashtags\",\"count\":0,\"scripted\":false},{\"type\":\"date\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"created_at\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"user.raw\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":true,\"doc_values\":false,\"name\":\"language\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"sentiment.raw\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":true,\"doc_values\":false,\"name\":\"text\",\"count\":0,\"scripted\":false},{\"type\":\"number\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"retweet\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"language.raw\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"hashtags.raw\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":false,\"doc_values\":false,\"name\":\"text.raw\",\"count\":0,\"scripted\":false},{\"type\":\"string\",\"indexed\":true,\"analyzed\":true,\"doc_values\":false,\"name\":\"user\",\"count\":0,\"scripted\":false}]"}
'

## Set fielddata true
curl -XPUT 'localhost:9200/twitter/_mapping/tweet?pretty' -H 'Content-Type: application/json' -d'
{
  "properties": {
    "sentiment": { 
      "type":     "text",
      "fielddata": true
    }
  }
}
'

curl -XPUT 'localhost:9200/twitter/_mapping/tweet?pretty' -H 'Content-Type: application/json' -d'
{
  "properties": {
    "text": { 
      "type":     "text",
      "fielddata": true
    }
  }
}
'

curl -XPUT 'localhost:9200/twitter/_mapping/tweet?pretty' -H 'Content-Type: application/json' -d'
{
  "properties": {
    "hashtags": { 
      "type":     "text",
      "fielddata": true
    }
  }
}
'

curl -XPUT 'localhost:9200/twitter/_mapping/tweet?pretty' -H 'Content-Type: application/json' -d'
{
  "properties": {
    "language": { 
      "type":     "text",
      "fielddata": true
    }
  }
}
'


## Get Search
#curl -XGET "http://localhost:9200/.kibana/search/All-tweets?pretty=1"

## Get dashboard
#curl -XGET "http://localhost:9200/.kibana/dashboard/dashboard_name?pretty=1"

## Get visualization
#curl -XGET "http://localhost:9200/.kibana/visualization/visualization-name?pretty=1"

## Import Search: All-Tweets
curl -XPUT 'localhost:9200/.kibana/search/All-tweets?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "All tweets",
    "description" : "",
    "hits" : 0,
    "columns" : [
      "_source"
    ],
    "sort" : [
      "_score",
      "desc"
    ],
    "version" : 1,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"index\":\"twitter\",\"highlight\":{\"pre_tags\":[\"@kibana-highlighted-field@\"],\"post_tags\":[\"@/kibana-highlighted-field@\"],\"fields\":{\"*\":{}}},\"filter\":[],\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}}}"
    }
}
'

## Import Visualization 1: QuarterHourly-Analysis
curl -XPUT 'localhost:9200/.kibana/visualization/QuarterHourly-Analysis?pretty' -H 'Content-Type: application/json' -d'
{
  "title" : "QuarterHourly Analysis",
  "visState" : "{\"type\":\"line\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"showCircles\":true,\"smoothLines\":false,\"interpolate\":\"linear\",\"scale\":\"linear\",\"drawLinesBetweenPoints\":true,\"radiusRatio\":\"55\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{}},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"created_at\",\"interval\":\"custom\",\"customInterval\":\"15m\",\"min_doc_count\":1,\"extended_bounds\":{}}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"group\",\"params\":{\"field\":\"sentiment\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{},\"title\":\"QuarterHourly Analysis\"}",
  "uiStateJSON" : "{}",
  "description" : "",
  "version" : 1,
  "kibanaSavedObjectMeta" : {
    "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
  }
}
'

## Import Visualization 2: PIE-Sentiment-Language
curl -XPUT 'localhost:9200/.kibana/visualization/PIE-Sentiment-Language?pretty' -H 'Content-Type: application/json' -d'
{
  "title" : "PIE Sentiment Language",
  "visState" : "{\"aggs\":[{\"id\":\"1\",\"params\":{},\"schema\":\"metric\",\"type\":\"count\"},{\"id\":\"3\",\"params\":{\"field\":\"language\",\"order\":\"desc\",\"orderBy\":\"1\",\"size\":5},\"schema\":\"segment\",\"type\":\"terms\"},{\"id\":\"4\",\"params\":{\"field\":\"sentiment\",\"order\":\"desc\",\"orderBy\":\"1\",\"size\":5},\"schema\":\"segment\",\"type\":\"terms\"}],\"listeners\":{},\"params\":{\"addLegend\":true,\"addTooltip\":true,\"isDonut\":false,\"shareYAxis\":true},\"type\":\"pie\",\"title\":\"PIE Sentiment Language\"}",
  "uiStateJSON" : "{}",
  "description" : "",
  "version" : 1,
  "kibanaSavedObjectMeta" : {
    "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}},\"filter\":[]}"
  }
}
'

## Import Visualization 3: Sentiments
curl -XPUT 'localhost:9200/.kibana/visualization/Sentiments?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "Sentiments",
    "visState" : "{\"type\":\"table\",\"params\":{\"perPage\":5,\"showMeticsAtAllLevels\":false,\"showPartialRows\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"bucket\",\"params\":{\"field\":\"sentiment\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{},\"title\":\"Sentiments\"}",
    "uiStateJSON" : "{}",
    "description" : "",
    "version" : 1,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}},\"filter\":[]}"
    }
}
'

## Import Visualization 4: Total-Tweets
curl -XPUT 'localhost:9200/.kibana/visualization/Total-Tweets?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "Total Tweets",
    "visState" : "{\"type\":\"metric\",\"params\":{\"fontSize\":60},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}}],\"listeners\":{},\"title\":\"Total Tweets\"}",
    "uiStateJSON" : "{}",
    "description" : "",
    "version" : 1,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
    }
}
'

## Import Visualization 5: Trending-HashTags
curl -XPUT 'localhost:9200/.kibana/visualization/Trending-HashTags?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "Trending HashTags",
    "visState" : "{\"type\":\"pie\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"isDonut\":false},\"aggs\":[{\"id\":\"1\",\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"hashtags\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"custom\",\"orderAgg\":{\"id\":\"2-orderAgg\",\"type\":\"count\",\"schema\":{\"group\":\"none\",\"name\":\"orderAgg\",\"title\":\"Order Agg\",\"aggFilter\":[\"!percentiles\",\"!median\",\"!std_dev\"],\"min\":0,\"max\":null,\"editor\":false,\"params\":[],\"deprecate\":false},\"params\":{}}}},{\"id\":\"3\",\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"sentiment\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{},\"title\":\"Trending HashTags\"}",
    "uiStateJSON" : "{}",
    "description" : "",
    "version" : 1,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
    }
}
'

## Import Visualization 6: realDonaldTrump-JebBush-HillaryClinton
curl -XPUT 'localhost:9200/.kibana/visualization/realDonaldTrump-JebBush-HillaryClinton?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "realDonaldTrump JebBush HillaryClinton",
    "visState" : "{\"title\":\"realDonaldTrump JebBush HillaryClinton\",\"type\":\"histogram\",\"params\":{\"shareYAxis\":true,\"addTooltip\":true,\"addLegend\":true,\"scale\":\"linear\",\"mode\":\"grouped\",\"times\":[],\"addTimeMarker\":false,\"defaultYExtents\":false,\"setYExtents\":false,\"yAxis\":{},\"legendPosition\":\"right\"},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"sentiment\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}],\"listeners\":{}}",    "uiStateJSON" : "{}",
    "description" : "",
    "version" : 1,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"index\":\"twitter\",\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
    }
}
'

## Import Dashboard: Twitter Sentiment DashBoard
curl -XPUT 'localhost:9200/.kibana/dashboard/Twitter-Sentiment-DashBoard?pretty' -H 'Content-Type: application/json' -d'
{
    "title" : "Twitter Sentiment DashBoard",
    "hits" : 0,
    "description" : "",
    "panelsJSON" : "[{\"col\":1,\"id\":\"PIE-Sentiment-Language\",\"row\":13,\"size_x\":5,\"size_y\":4,\"type\":\"visualization\"},{\"col\":6,\"id\":\"Trending-HashTags\",\"row\":13,\"size_x\":7,\"size_y\":4,\"type\":\"visualization\"},{\"col\":5,\"id\":\"QuarterHourly-Analysis\",\"row\":1,\"size_x\":8,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"Total-Tweets\",\"row\":5,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"col\":1,\"id\":\"Sentiments\",\"row\":1,\"size_x\":4,\"size_y\":4,\"type\":\"visualization\"},{\"id\":\"realDonaldTrump-JebBush-HillaryClinton\",\"type\":\"visualization\",\"size_x\":8,\"size_y\":4,\"col\":5,\"row\":5}]",
    "optionsJSON" : "{\"darkTheme\":false}",
    "uiStateJSON" : "{}",
    "version" : 1,
    "timeRestore" : false,
    "kibanaSavedObjectMeta" : {
      "searchSourceJSON" : "{\"filter\":[{\"query\":{\"query_string\":{\"analyze_wildcard\":true,\"query\":\"*\"}}}]}"
    }
}
'
