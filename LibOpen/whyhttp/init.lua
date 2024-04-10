--!strict
-- whyhttp - Parsing and formatting for HTTP status codes
-- (c) Daniel P H Fox, licensed under MIT

local whyhttp = {}

export type HttpCode = {
	name: string,
	code: number,
	describe: Describer
}

export type Verbs = {
	theNoun: string,
	verb: string,
	verbed: string,
	verbing: string
}
local THE_NOUN = "THE_NOUN"
local VERB = "VERB"
local VERBED = "VERBED"
local VERBING = "VERBING"

local function verbify(
	str: string,
	verbs: Verbs
): string
	return str
		:gsub("^"..THE_NOUN, verbs.theNoun:sub(1, 1):upper() .. verbs.theNoun:sub(2))
		:gsub(THE_NOUN, verbs.theNoun)
		:gsub(VERB, verbs.verb)
		:gsub(VERBED, verbs.verbed)
		:gsub(VERBING, verbs.verbing)
end

export type Describer = (HttpCode, Verbs) -> Description

export type Description = {
	brief: string,
	details: string?,
	tip: string?
}

local function standardDescribe(
	code: HttpCode,
	verbs: Verbs
): Description
	if code.code >= 400 then
		return {
			brief = `Couldn't {verbs.verb} due to an error.`,
			details = `HTTP code {code.code} ({code.name})`,
			tip = "Check your network connection and try again in a moment."
		}
	elseif code.code >= 300 then
		return {
			brief = `Tried to {verbs.verb} but the server redirected the request.`,
			details = `HTTP code {code.code} ({code.name})`,
			tip = "The website or service might have moved. If you weren't expecting this, try again in a moment."
		}
	elseif code.code >= 200 then
		return {
			brief = `Successfully {verbs.verbed}.`,
			details = `HTTP code {code.code} ({code.name})`
		}
	else
		return {
			brief = `Started {verbs.verbing}.`,
			details = `HTTP code {code.code} ({code.name})`
		}
	end		
end

local function makeDescriber(
	structure: {
		brief: string,
		details: string?,
		tip: string?
	}
): Describer
	return function(_, verbs)
		local description = {}
		description.brief = verbify(structure.brief, verbs)
		if structure.details then
			description.details = verbify(structure.details, verbs)
		end
		if structure.tip then
			description.tip = verbify(structure.tip, verbs)
		end
		return description
	end
end

local CODES: {[number]: HttpCode} = {
	-- Informational responses

	[100] = {
		name = "Continue",
		code = 100,
		describe = standardDescribe
	},
	[101] = {
		name = "Switching Protocols",
		code = 101,
		describe = standardDescribe
	},
	[102] = {
		name = "Processing",
		code = 102,
		describe = standardDescribe
	},
	[103] = {
		name = "Early Hints",
		code = 103,
		describe = standardDescribe
	},

	-- Successful responses

	[200] = {
		name = "OK",
		code = 200,
		describe = makeDescriber {
			brief = `Successfully {VERBED}.`
		}
	},
	[201] = {
		name = "Created",
		code = 201,
		describe = makeDescriber {
			brief = `Successfully created {THE_NOUN}.`
		}
	},
	[202] = {
		name = "Accepted",
		code = 202,
		describe = makeDescriber {
			brief = `The request to {VERB} has been received.`
		}
	},
	[203] = {
		name = "Non-Authoritative Information",
		code = 203,
		describe = makeDescriber {
			brief = `Successfully {VERBED}, but any returned data might differ from the source.`
		}
	},
	[204] = {
		name = "No Content",
		code = 204,
		describe = makeDescriber {
			brief = `Successfully {VERBED}, but there is no content.`
		}
	},
	[205] = {
		name = "Reset Content",
		code = 205,
		describe = standardDescribe
	},
	[206] = {
		name = "Partial Content",
		code = 206,
		describe = standardDescribe
	},
	[207] = {
		name = "Multi Status",
		code = 207,
		describe = standardDescribe
	},
	[208] = {
		name = "Already Reported",
		code = 208,
		describe = standardDescribe
	},
	[226] = {
		name = "IM Used",
		code = 226,
		describe = standardDescribe
	},

	-- Redirection responses

	[300] = {
		name = "Multiple Choices",
		code = 300,
		describe = standardDescribe
	},
	[301] = {
		name = "Moved Permanently",
		code = 301,
		describe = standardDescribe
	},
	[302] = {
		name = "Found",
		code = 302,
		describe = standardDescribe
	},
	[303] = {
		name = "See Other",
		code = 303,
		describe = standardDescribe
	},
	[304] = {
		name = "Not Modified",
		code = 304,
		describe = standardDescribe
	},
	[305] = {
		name = "Use Proxy",
		code = 305,
		describe = standardDescribe
	},
	[307] = {
		name = "Temporary Redirect",
		code = 307,
		describe = standardDescribe
	},
	[308] = {
		name = "Permanent Redirect",
		code = 308,
		describe = standardDescribe
	},

	-- Client error responses

	[400] = {
		name = "Bad Request",
		code = 400,
		describe = makeDescriber {
			brief = `Couldn't {VERB} because the request was not valid.`
		}
	},
	[401] = {
		name = "Unauthorized",
		code = 401,
		describe = makeDescriber {
			brief = `Authentication is required to {VERB}.`
		}
	},
	[402] = {
		name = "Payment Required",
		code = 402,
		describe = makeDescriber {
			brief = `Payment is required to {VERB}.`
		}
	},
	[403] = {
		name = "Forbidden",
		code = 403,
		describe = makeDescriber {
			brief = `Authorisation is required to {VERB}.`
		}
	},
	[404] = {
		name = "Not Found",
		code = 404,
		describe = makeDescriber {
			brief = `{THE_NOUN} can't be found.`,
			tip = "This might indicate a service outage. If you didn't expect this, try again later or get in touch."
		}
	},
	[405] = {
		name = "Method Not Allowed",
		code = 405,
		describe = standardDescribe
	},
	[406] = {
		name = "Not Acceptable",
		code = 406,
		describe = standardDescribe
	},
	[407] = {
		name = "Proxy Authentication Required",
		code = 407,
		describe = standardDescribe
	},
	[408] = {
		name = "Request Timeout",
		code = 408,
		describe = makeDescriber {
			brief = `Tried to {VERB}, but it took too long.`,
			tip = "Try again in a few moments. If this continues, get in touch."
		}
	},
	[409] = {
		name = "Conflict",
		code = 409,
		describe = standardDescribe
	},
	[410] = {
		name = "Gone",
		code = 410,
		describe = makeDescriber {
			brief = `{THE_NOUN} has been permanently deleted from the server.`,
			tip = "If you didn't expect this, you might be running on an old version - check for updates."
		}
	},
	[411] = {
		name = "Length Required",
		code = 411,
		describe = standardDescribe
	},
	[412] = {
		name = "Precondition Failed",
		code = 412,
		describe = standardDescribe
	},
	[413] = {
		name = "Payload Too Large",
		code = 413,
		describe = standardDescribe
	},
	[414] = {
		name = "URI Too Long",
		code = 414,
		describe = standardDescribe
	},
	[415] = {
		name = "Unsupported Media Type",
		code = 415,
		describe = standardDescribe
	},
	[416] = {
		name = "Range Not Satisfiable",
		code = 416,
		describe = standardDescribe
	},
	[417] = {
		name = "Expectation Failed",
		code = 417,
		describe = standardDescribe
	},
	[418] = {
		name = "I'm a teapot",
		code = 418,
		describe = makeDescriber {
			brief = "Couldn't brew coffee with a teapot.",
			tip = "Try providing tea instead."
		}
	},
	[421] = {
		name = "Misdirected Request",
		code = 421,
		describe = standardDescribe
	},
	[422] = {
		name = "Unprocessable Content",
		code = 422,
		describe = standardDescribe
	},
	[423] = {
		name = "Locked",
		code = 423,
		describe = standardDescribe
	},
	[424] = {
		name = "Failed Dependency",
		code = 424,
		describe = standardDescribe
	},
	[425] = {
		name = "Too Early",
		code = 425,
		describe = standardDescribe
	},
	[426] = {
		name = "Upgrade Required",
		code = 426,
		describe = standardDescribe
	},
	[428] = {
		name = "Precondition Required",
		code = 428,
		describe = standardDescribe
	},
	[429] = {
		name = "Too Many Requests",
		code = 429,
		describe = makeDescriber {
			brief = `Tried to {VERB} too many times.`,
			tip = "Wait for a few minutes before trying again."
		}
	},
	[431] = {
		name = "Request Header Fields Too Large",
		code = 431,
		describe = standardDescribe
	},
	[451] = {
		name = "Unavailable For Legal Reasons",
		code = 451,
		describe = makeDescriber {
			brief = `{THE_NOUN} is unavailable for legal reasons.`,
			tip = `Ensure your region has access to {THE_NOUN}.`
		}
	},

	-- Server error responses

	[500] = {
		name = "Internal Server Error",
		code = 500,
		describe = makeDescriber {
			brief = `The online service errored while trying to {VERB}.`,
			tip = "Try again in a few moments. If this continues, get in touch."
		}
	},
	[501] = {
		name = "Not Implemented",
		code = 501,
		describe = standardDescribe
	},
	[502] = {
		name = "Bad Gateway",
		code = 502,
		describe = makeDescriber {
			brief = `Couldn't {VERB} because the service couldn't get a valid response.`,
			tip = "Try again in a few moments. If this continues, get in touch."
		}
	},
	[503] = {
		name = "Service Unavailable",
		code = 503,
		describe = makeDescriber {
			brief = `Couldn't {VERB} because the service is unavailable.`,
			tip = "The service might be under maintenance or experiencing high volumes of traffic. Try again later."
		}
	},
	[504] = {
		name = "Gateway Timeout",
		code = 504,
		describe = makeDescriber {
			brief = `Couldn't {VERB} because the service couldn't get a response in time.`,
			tip = "Try again in a few moments. If this continues, get in touch."
		}
	},
	[505] = {
		name = "HTTP Version Not Supported",
		code = 505,
		describe = standardDescribe
	},
	[506] = {
		name = "Variant Also Negotiates",
		code = 506,
		describe = standardDescribe
	},
	[507] = {
		name = "Insufficient Storage",
		code = 507,
		describe = standardDescribe
	},
	[508] = {
		name = "Loop Detected",
		code = 508,
		describe = standardDescribe
	},
	[510] = {
		name = "Not Extended",
		code = 510,
		describe = standardDescribe
	},
	[511] = {
		name = "Network Authentication Required",
		code = 511,
		describe = makeDescriber {
			brief = `Authentication is required to {VERB}.`
		}
	},
}

whyhttp.codes = CODES

function whyhttp.codeFromError(
	err: string
): HttpCode?
	local match = string.match(err, "HTTP (%d%d%d)")
	if not match then
		return nil
	else
		local code = tonumber(match)
		if code == nil then
			return nil
		end
		return CODES[code]
	end
end

local function unknownDescribe(
	err: string,
	verbs: Verbs
): Description
	return {
		brief = `Couldn't {verbs.verb} due to an error.`,
		details = `Unknown error: {err}`,
		tip = "Check your network connection and try again in a moment. If this persists, get in touch."
	}	
end

local otherDescribers = {
	{
		matches = "ConnectFail",
		describe = function(
			err: string, 
			verbs: Verbs
		): Description
			return {
				brief = `Failed to connect and {verbs.verb}.`,
				tip = "Check your internet connection and try again."
			}
		end
	}
}

function whyhttp.describeError(
	err: string,
	verbs: Verbs
): Description
	local code = whyhttp.codeFromError(err)
	if code == nil then
		for _, otherDescriber in otherDescribers do
			if string.match(err, otherDescriber.matches) ~= nil then
				return otherDescriber.describe(err, verbs)
			end
		end
		return unknownDescribe(err, verbs)
	else
		return code:describe(verbs)
	end
end

return whyhttp