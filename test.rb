
regex = /(cite|citenp):([^\[]*)\[((?:([^\s,()\[\]]+)(\([^)]*\))?(\s*,\s*([^\s,()\[\]]+)(\([^)]*\))?)*))\]/

# matches a citation type
CITATION_TYPE = /cite|citenp/.freeze
# matches a citation item (key + locator), such as 'Dan2012(99-100)'
CITATION_ITEM = /([^\s,()\[\]]+)(\([^)]*\))?/.freeze
# matches a citation list
CITATION_LIST_TAIL = /(\s*,\s*#{CITATION_ITEM.source})*/.freeze
CITATION_LIST = /(?:#{CITATION_ITEM.source}#{CITATION_LIST_TAIL.source})/.freeze
CITATION_PRETEXT = /[^\[]*/.freeze
# matches the full citation macro
CITATION_MACRO = /(#{CITATION_TYPE.source}):(#{CITATION_PRETEXT.source})\[(#{CITATION_LIST.source})\]/.freeze

line = "Author-year references can use different styles such as: cite:see[Lane12b(11)]"

p CITATION_MACRO.match line