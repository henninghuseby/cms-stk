<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:portal="http://www.enonic.com/cms/xslt/portal" 
   xmlns:stk="http://www.enonic.com/cms/xslt/stk">
   
   <xsl:import href="stk-variables.xsl"/>
   <xsl:import href="system.xsl"/>   
   <xsl:import href="file.xsl"/>
   
   <!-- Metadata template -->
   <xsl:template name="stk:head.create-metadata" as="element()*">
      <xsl:param name="description" as="xs:string?"/>
      <xsl:param name="keywords" as="xs:string?"/>
      
      <xsl:variable name="stk:head.meta-generator" select="stk:system.get-config-param('meta-generator', $stk:path)" as="element()?"/>
      <xsl:variable name="stk:head.meta-author" select="stk:system.get-config-param('meta-author', $stk:path)" as="element()?"/>      
      <xsl:variable name="stk:head.meta-google-site-verification" select="stk:system.get-config-param('google-site-verification', $stk:path)" as="element()?"/>
      
      <xsl:variable name="stk:head.meta-description">
         <xsl:choose>
            <xsl:when test="/result/contents/content/contentdata/meta-description != ''">
               <xsl:value-of select="/result/contents/content/contentdata/meta-description"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$stk:current-resource/description"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="stk:head.meta-keywords">
         <xsl:choose>
            <xsl:when test="/result/contents/content/contentdata/meta-keywords != ''">
               <xsl:value-of select="/result/contents/content/contentdata/meta-keywords"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$stk:current-resource/keywords"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="stk:head.meta-content-key">
         <xsl:value-of select="/result/context/resource[@type = 'content']/@key"/>
      </xsl:variable>
      <xsl:variable name="stk:head.meta-content-type">
         <xsl:value-of select="/result/context/resource[@type = 'content']/type"/>
      </xsl:variable>      
      
      <meta charset="utf-8"/>
      <meta content="IE=Edge" http-equiv="X-UA-Compatible"/>
      
      <xsl:if test="normalize-space($stk:head.meta-generator)">
         <meta name="generator" content="{$stk:head.meta-generator}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($stk:head.meta-author)">
         <meta name="author" content="{$stk:head.meta-author}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($description) or normalize-space($stk:head.meta-description)">
         <meta name="description" content="{if (normalize-space($description)) then $description else $stk:head.meta-description}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($keywords) or normalize-space($stk:head.meta-keywords)">
         <meta name="keywords" content="{if (normalize-space($keywords)) then $keywords else $stk:head.meta-keywords}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($stk:head.meta-google-site-verification)">
         <meta name="google-site-verification" content="{$stk:head.meta-google-site-verification}"/>
      </xsl:if>
      
      <meta content="minimum-scale=1.0, width=device-width, user-scalable=yes" name="viewport" />
      <meta name="apple-mobile-web-app-capable" content="yes" />
      
      
      <!-- for Google Search Appliance -->
      <xsl:if test="stk:system.get-config-param('gsa-version', $stk:path)">
         <xsl:if test="normalize-space($stk:head.meta-content-key)">
            <meta name="{if (number(stk:system.get-config-param('gsa-version', $stk:path)) ge 1.1) then 'dcterms.identifier' else '_key'}" content="{$stk:head.meta-content-key}"/>
         </xsl:if>
         <xsl:if test="normalize-space($stk:head.meta-content-type)">
            <meta name="{if (number(stk:system.get-config-param('gsa-version', $stk:path)) ge 1.1) then 'dcterms.type' else '_cty'}" content="{$stk:head.meta-content-type}"/>
         </xsl:if>
      </xsl:if>
      
   </xsl:template>
   
   <!-- Css common template -->
   <!-- Renders all CSS files defined in theme.xml  -->
   <xsl:template name="stk:head.create-css">
      <!-- resources without a condition -->
      <xsl:for-each select="($stk:theme-all-devices | $stk:theme-device-class)/styles/style[normalize-space(path)][not(normalize-space(condition))][stk:head.check-resource-include-filter(.)]">
         <xsl:variable name="resource-url" as="xs:string">
            <xsl:apply-templates select="." mode="stk:head"/>
         </xsl:variable>
         <link rel="stylesheet" href="{$resource-url}">            
            <xsl:if test="stk:file.get-extension(path) = 'less'">
               <xsl:attribute name="rel" select="'stylesheet/less'"/>
            </xsl:if>
            <xsl:if test="normalize-space(media)">
               <xsl:attribute name="media">
                  <xsl:value-of select="media"/>
               </xsl:attribute>
            </xsl:if>
         </link>
      </xsl:for-each>
      <!-- resources with a condition -->
      <xsl:for-each-group select="($stk:theme-all-devices | $stk:theme-device-class)/styles/style[normalize-space(path)][stk:head.check-resource-include-filter(.)]" group-by="condition">  
         <xsl:text disable-output-escaping="yes">&lt;!--[if </xsl:text>
         <xsl:value-of select="current-grouping-key()"/>
         <xsl:text disable-output-escaping="yes">]&gt;</xsl:text>
         <xsl:for-each select="current-group()">
            <xsl:variable name="resource-url" as="xs:string">
               <xsl:apply-templates select="." mode="stk:head"/>
            </xsl:variable>
            <link rel="stylesheet" href="{$resource-url}">
               <xsl:if test="stk:file.get-extension(path) = 'less'">
                  <xsl:attribute name="rel" select="'stylesheet/less'"/>
               </xsl:if>
               <xsl:if test="normalize-space(media)">
                  <xsl:attribute name="media">
                     <xsl:value-of select="media"/>
                  </xsl:attribute>
               </xsl:if>
            </link>
         </xsl:for-each>
         <xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
      </xsl:for-each-group>
   </xsl:template>
   
   <!-- Script common template -->
   <!-- Renders all javascript for current device as defined in the theme.xml -->
   <xsl:template name="stk:head.create-js">      
      <script>
         <xsl:text>head.js(</xsl:text>
         <xsl:for-each select="($stk:theme-all-devices | $stk:theme-device-class)/scripts/script[normalize-space(path)][not(normalize-space(condition))][stk:head.check-resource-include-filter(.)]">
            <xsl:variable name="resource-url" as="xs:string">
               <xsl:apply-templates select="." mode="stk:head"/>
            </xsl:variable>
            <xsl:text>'</xsl:text>
            <xsl:value-of select="$resource-url"/>
            <xsl:text>'</xsl:text>
            <xsl:if test="position() != last()">
               <xsl:text>,</xsl:text>
            </xsl:if>
            
         </xsl:for-each>   
         <xsl:text>);</xsl:text>
      </script>
      
      <xsl:for-each-group select="($stk:theme-all-devices | $stk:theme-device-class)/scripts/script[normalize-space(path)][stk:head.check-resource-include-filter(.)]" group-by="condition">            
         <xsl:text disable-output-escaping="yes"> &lt;!--[if </xsl:text>
         <xsl:value-of select="current-grouping-key()"/>
         <xsl:text disable-output-escaping="yes">]&gt; </xsl:text>
         <script>
            <xsl:text>head.js(</xsl:text>
            <xsl:for-each select="current-group()">
               <xsl:variable name="resource-url" as="xs:string">
                  <xsl:apply-templates select="." mode="stk:head"/>
               </xsl:variable>
               <xsl:text>'</xsl:text>
               <xsl:value-of select="$resource-url"/>
               <xsl:text>'</xsl:text>
               <xsl:if test="position() != last()">
                  <xsl:text>,</xsl:text>
               </xsl:if>
            </xsl:for-each>
            <xsl:text>);</xsl:text>
         </script>
         <xsl:text disable-output-escaping="yes"> &lt;![endif]--&gt; </xsl:text>
      </xsl:for-each-group>
   </xsl:template>
   
   <xsl:template match="style|script" mode="stk:head">
      <xsl:choose>
         <!-- external resource -->
         <xsl:when test="matches(path, '^(http(s)?:)?//')">
            <xsl:value-of select="path"/>
         </xsl:when>
         <!-- theme or stk resource -->
         <xsl:when test="matches(path, '\{theme\}|\{stk\}')">
            <xsl:value-of select="stk:file.create-resource-url(path)"/>
         </xsl:when>
         <!-- other local resources -->
         <xsl:otherwise>
            <xsl:value-of select="portal:createResourceUrl(path)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:function name="stk:head.check-resource-include-filter" as="xs:boolean">
      <xsl:param name="resource" as="element()"/>
      
      <xsl:choose>
         <xsl:when test="$resource/includes/include = $stk:path">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:when test="$resource/includes/include[starts-with($stk:path, string(.))][@recursive = 'true']">
            <xsl:choose>
               <xsl:when test="$resource/excludes/exclude[starts-with($stk:path, string(.))][@recursive = 'true']">
                  <xsl:value-of select="false()"/>
               </xsl:when>
               <xsl:when test="$resource/excludes/exclude = $stk:path">
                  <xsl:value-of select="false()"/>
               </xsl:when>  
               <xsl:otherwise>                  
                  <xsl:value-of select="true()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$resource/includes/include">            
            <xsl:value-of select="false()"/>
         </xsl:when>
         <xsl:when test="$resource/excludes/exclude[starts-with($stk:path, string(.))][@recursive = 'true']">
            <xsl:value-of select="false()"/>
         </xsl:when>
         <xsl:when test="$resource/excludes/exclude = $stk:path">
            <xsl:value-of select="false()"/>
         </xsl:when>         
         <xsl:otherwise>
            <xsl:value-of select="true()"/>
         </xsl:otherwise>         
      </xsl:choose>
   </xsl:function>
   
</xsl:stylesheet>
