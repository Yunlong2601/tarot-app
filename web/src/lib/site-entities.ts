import { SITE_URL, SUPPORT_EMAIL } from "../config.ts";

export const SHENETIC = {
  "@type": "Organization",
  "@id": SITE_URL + "#shenetic",
  name: "Shenetic",
  url: SITE_URL,
  brand: { "@type": "Brand", name: "ShenTarot" },
};

export const SHENETIC_PROFILE = {
  ...SHENETIC,
  email: SUPPORT_EMAIL,
  logo: { "@type": "ImageObject", url: new URL("icon.png", SITE_URL).href },
  address: { "@type": "PostalAddress", addressCountry: "SG" },
};

export const SHENTAROT_WEBSITE = {
  "@type": "WebSite",
  "@id": SITE_URL + "#website",
  name: "ShenTarot",
  url: SITE_URL,
  publisher: { "@id": SHENETIC["@id"] },
  isAccessibleForFree: true,
};
