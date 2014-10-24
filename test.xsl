<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="doc/str">
        <xsl:for-each select="descMeta">
            <mods:mods
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
                <xsl:apply-templates/>
            </mods:mods>
        </xsl:for-each>
    </xsl:template>
    
     <xsl:template match="mediaType">
        <xsl:for-each select=".[@type]">
            <mods:resourceType>
                <xsl:if test="@type='sound'"><xsl:text>sound recording</xsl:text></xsl:if>
                <xsl:if test="@type='movingImage'"><xsl:text>moving image</xsl:text></xsl:if>
                <xsl:if test="@type='text'"><xsl:text>text</xsl:text></xsl:if>
                <xsl:if test="@type='image'"><xsl:text>still image</xsl:text></xsl:if>
                <xsl:if test="@type='collection'"><xsl:attribute name="collection">yes</xsl:attribute><xsl:text>mixed material</xsl:text></xsl:if>
            </mods:resourceType>
        </xsl:for-each>
    </xsl:template> 
    
      <xsl:template match="title">
        <xsl:for-each select=".">   
            <xsl:choose>
             <xsl:when test="@xml:Lang='ja'">
                <mods:titleInfo xml:Lang="ja">
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </mods:titleInfo>
            </xsl:when>
            <!-- can't get xml:Lang="ja" to appear in titleInfo attribute?? -->
            <xsl:when test="@xml:lang='ja-Latn'">
                <mods:titleInfo type="translated" xml:Lang="ja-Latn">
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </mods:titleInfo>
            </xsl:when>
            <xsl:when test="@type='alternate'">
                <mods:titleInfo type="alternative">
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </mods:titleInfo>
            </xsl:when>
            <xsl:otherwise>
                <mods:titleInfo>
                    <mods:title>
                        <xsl:value-of select="."/>
                    </mods:title>
                </mods:titleInfo>
            </xsl:otherwise>
        </xsl:choose>        
      </xsl:for-each>
    </xsl:template>
    
  <xsl:template match="agent[@type='creator']|agent[@type='contributor']">
      <xsl:for-each select=".[@type='creator']|.[@type='contributor']">
            <xsl:choose>
                <xsl:when test="persName">
                    <mods:name>
                       <xsl:attribute name="type">
                           <xsl:text>personal</xsl:text>
                       </xsl:attribute>
                    <xsl:value-of select="persName"/>
                    </mods:name>
                </xsl:when>
                <xsl:when test="corpName">
                    <mods:name>
                        <xsl:attribute name="type">
                            <xsl:text>corporate</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="corpName"/>
                    </mods:name>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- map publisher to mods:originInfo/publisher element. Need to create templates to enable combining publisher, date, publication location under originInfo -->
      <xsl:template match="agent[@role='publisher']">
           <xsl:for-each select=".[@role='publisher']">
               <xsl:choose>
                   <xsl:when test="@role='publisher'">
                    <mods:originInfo>
                        <mods:publisher>
                            <xsl:value-of select="."/>
                        </mods:publisher>
                     </mods:originInfo>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each> 
    </xsl:template>
    
  
    <xsl:template match="covTime | subject[@type='temporal']">
        <xsl:for-each select="date">
            <xsl:choose>
                <xsl:when test="date[@certainty='circa']">
                  <mods:dateCreated qualifier="approximate">
                     <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:when> 
                <xsl:when test="date[@certainty='exact']">
                    <mods:dateCreated>
                        <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:when> 
             <xsl:otherwise>
                 <mods:dateCreated>
                     <xsl:value-of select="."/>
                 </mods:dateCreated>
             </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="covPlace">
        <xsl:for-each select=".">

                <mods:place>
                    <mods:placeTerm type="text">
                        <xsl:call-template name="join">
                            <xsl:with-param name="list" select="geogName" />
                            <xsl:with-param name="separator" select="', '" />
                        </xsl:call-template>
                    </mods:placeTerm>
                </mods:place>
<!-- preliminary work - this needs to go within mods:originInfo with publisher and dateCreated -->
        </xsl:for-each>
    </xsl:template>
    
    <!-- need to decide what to do with form. do we match them to LOC genre terms (not always an exact match)? Need to find out what forms are in use currently in Fedora and go from there. -->

 <xsl:template match="physDesc">
     
     <physicalDescription>
         <xsl:for-each select=".">
        <extent>
            <xsl:call-template name="join">
                <xsl:with-param name="list" select="extent | extent[@units/text()] | size | size[@units/text()]"/>
                <xsl:with-param name="separator" select="', '" />
            </xsl:call-template>
        </extent>
             <!-- cannot figure out how to get the extent and size units to appear at the moment -->
         </xsl:for-each>
         <xsl:for-each select="format">
         <format>
             <xsl:value-of select="."/>
         </format>
            
        </xsl:for-each>
     </physicalDescription>
 </xsl:template>    

<xsl:template match="description">
    <xsl:for-each select=".[@type='summary']">
        <abstract display-label="summary">
            <xsl:value-of select="."/>
        </abstract>
    </xsl:for-each>
    <xsl:for-each select=".[@type='credits']">
        <note type="creation/production credits">
            <xsl:value-of select="."/>
        </note>
    </xsl:for-each>
</xsl:template>

<xsl:template match="language">
<xsl:for-each select=".">
    <mods:language>
        <mods:languageTerm type="code">
               <xsl:value-of select="."/>
        </mods:languageTerm>
    </mods:language>

</xsl:for-each>
</xsl:template>
    
    <xsl:template match="identifier">
        <xsl:for-each select=".">
            <mods:identifier>
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="repository">
        <xsl:for-each select="corpName">
            <mods:location>
                <mods:physicalLocation>
                    <xsl:value-of select="."/>
                </mods:physicalLocation>
            </mods:location>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="culture">
        <xsl:for-each select="."/>
      </xsl:template>
    <xsl:template match="rights">
        <xsl:for-each select=".">
            <mods:accessCondition>
                <xsl:value-of select="."/>
            </mods:accessCondition>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="subject">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test=".[@scheme='LCSH']">
                          <mods:subject>
                   <xsl:attribute name="authority">
                            <xsl:text>lcsh</xsl:text>
                        </xsl:attribute>
                              <mods:topic>
                        <xsl:value-of select="."/>
                                 </mods:topic>
                    </mods:subject>
                </xsl:when>
                <xsl:when test=".[@type='temporal']">
                    <mods:subject>
                        <mods:temporal>
                            
                            <xsl:value-of select="decade"/>
                        </mods:temporal>
                    </mods:subject>
                </xsl:when>
                <xsl:when test=".[@type='geographical']">
                    <!-- need to evaluate if these are all in fact geographical subjects, or if they duplicate covPlace -->
                    <mods:subject>
                        <mods:geographic>
                            <xsl:call-template name="join">
                                <xsl:with-param name="list" select="geogName" />
                                <xsl:with-param name="separator" select="', '" />
                            </xsl:call-template>
                        </mods:geographic>
                    </mods:subject>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>   
    
    <xsl:template match="style">
        <xsl:for-each select=".">
            <mods:genre>
                <xsl:value-of select="."/>
            </mods:genre>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="relationships">
        <xsl:for-each select="relation">
            <xsl:choose>
                <xsl:when test=".[@label='citation']">
                    <mods:relatedItem>
                        <mods:title>
                            <xsl:value-of select="./bibref/title"/>
                        </mods:title>
                        <!-- should be able to apply templates here for agent, geogname, etc., that appear in the citation -->
                    </mods:relatedItem>
                </xsl:when>
                <xsl:when test=".[@label='archivalcollection']">
                    <mods:relatedItem>
                        <mods:title>
                            <xsl:value-of select="./bibref/title"/>
                        </mods:title>
                    </mods:relatedItem>
                </xsl:when>
           <xsl:otherwise>
            <mods:relatedItem>
                <mods:title>
                    <xsl:value-of select="./bibref/title"/>
                </mods:title>
            </mods:relatedItem>
           </xsl:otherwise>
            </xsl:choose>    
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="join">
        <xsl:param name="list" />
        <xsl:param name="separator"/>
        
        <xsl:for-each select="$list">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- can't find a MODS element that works for mapping price (which is used in Prange). There is one in MARC, but not in MODS. May just have to put into a generic notes field? -->
</xsl:stylesheet>
