<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:u="urn:schemas-microsoft-com:unattend">
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <!-- from https://www.oreilly.com/library/view/xslt-cookbook/0596003722/ch01s07.html -->
    <xsl:template name="search-and-replace-whole-words-only">
        <xsl:param name="input"/>
        <xsl:param name="search-string"/>
        <xsl:param name="replace-string"/>
        <xsl:choose>
            <!-- See if the input contains the search string -->
            <xsl:when test="contains($input,$search-string)">
                <!-- If so, then test that the before and after characters are word
                delimiters. -->
                <xsl:variable name="before"
                select="substring-before($input,$search-string)"/>
                <xsl:variable name="before-char"
                select="substring(concat(' ',$before),string-length($before) +1, 1)"/>
                <xsl:variable name="after"
                select="substring-after($input,$search-string)"/>
                <xsl:variable name="after-char"
                select="substring($after,1,1)"/>
                <xsl:value-of select="$before"/>
                <xsl:choose>
                    <xsl:when test="not(normalize-space($before-char)) and
                    not(normalize-space($after-char))">
                        <xsl:value-of select="$replace-string"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$search-string"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="search-and-replace-whole-words-only">
                    <xsl:with-param name="input" select="$after"/>
                    <xsl:with-param name="search-string" select="$search-string"/>
                    <xsl:with-param name="replace-string" select="$replace-string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- There are no more occurences of the search string so
                just return the current input string -->
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/u:unattend">
        <xsl:for-each select="u:settings[@pass='specialize']/u:component[@name='Microsoft-Windows-Deployment']/u:RunSynchronous/u:RunSynchronousCommand">
            <xsl:sort select="u:Order" data-type="number" />
            <xsl:call-template name="search-and-replace-whole-words-only">
                <xsl:with-param name="input" select="u:Path" />
                <xsl:with-param name="search-string">%i</xsl:with-param>
                <xsl:with-param name="replace-string">%%i</xsl:with-param>
            </xsl:call-template>
            <xsl:text>&#xD;&#xA;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="u:settings[@pass='oobeSystem']/u:component[@name='Microsoft-Windows-Shell-Setup']/u:FirstLogonCommands/u:SynchronousCommand">
            <xsl:sort select="u:Order" data-type="number" />
            <xsl:value-of select="u:CommandLine" />
            <xsl:text>&#xD;&#xA;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
