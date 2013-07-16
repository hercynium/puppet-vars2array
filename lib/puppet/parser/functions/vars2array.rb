
module Puppet::Parser::Functions
    newfunction(:vars2array, :type => :rvalue, :doc => <<-END

Given a regex pattern, collect the values of all vars from the current
scope with names that match, and return the values as an array.

*Description:*

*Required parameters:*

    * A string containing a valid ruby regexp

*Optional Parameters:*

    None

*Returns:*

  A data structure that looks like this:

  [ 'foo', 0, false, ... ]

  If no vars match the regex, an empty array will be returned.

*Errors:*

*Examples:*

    $array = vars2array( "^blkid_dev_\d+_tag_label" )

END
    ) do |args|

        require 'pp'
        Puppet.debug("starting function vars2array")

        # if extra args were passed, they will be used to add extra elements
        # to the array, extracting captures from the match if backrefs are used.
        pat_str, extra = args

        # precompile the pattern
        pat = Regexp.new( pat_str )

        # this should get all the vars available in the current scope
        # as a sorted array of pairs
        vars = self.to_hash \
             .select { |k,v| k.is_a?( String ) } \
             .sort { |a,b| a[0] <=> b[0] }

        arr = []
        vars.each { |pair|
            var_name, var_value = pair
            # see if it matched the pattern...
            if var_name.is_a?( String ) and md = pat.match( var_name )
                # if things were captured and the user wanted us to extract stuff...
                if md.captures.length and extra
                    # pull out only the substring that matched
                    beg_off = md.pre_match.length
                    end_off = md.post_match.length * -1 - 1
                    m_subst = var_name.slice( beg_off .. end_off )
                    # then use the sub method to handle building the extracted strings
                    extra_vals = extra.map { |ext| m_subst.sub( pat, ext ) }
                    # and add them to the output array
                    arr += extra_vals
                end
                # add the var's value
                arr << var_value
            end
        }
        Puppet.debug("finished function vars2array")
        return arr
    end
end

# vi: set ts=4 sw=4 et :
