"""Generates app/assets/cards/cards.json. All meaning text is original wording."""
import json, re, sys

MAJORS = [
("The Fool","beginnings,spontaneity,trust","A fresh start asks for a leap of faith. Stay curious and open to what is new.","Hesitation or carelessness. Pause to check the ground before you step.","Air"),
("The Magician","skill,focus,resourcefulness","You already hold the tools you need. Gather your attention and act with intent.","Scattered energy or unused talent. Ask what is holding your focus back.","Mercury"),
("The High Priestess","intuition,stillness,the unspoken","Quiet reflection brings answers that noise cannot. Trust what you sense beneath the surface.","Ignoring your inner voice, or keeping something hidden from yourself.","Moon"),
("The Empress","nurture,abundance,creativity","Care, comfort and growth are available. Tend what you love and let it flourish.","Smothering, neglecting yourself, or a creative block.","Venus"),
("The Emperor","structure,authority,stability","Clear boundaries and steady planning create a solid base. Lead with calm.","Rigidity or control. Ask where firmness has become stubbornness.","Aries"),
("The Hierophant","tradition,guidance,belonging","Learning from established wisdom or community can steady you.","Questioning rules that no longer fit. Find your own path to meaning.","Taurus"),
("The Lovers","choice,connection,alignment","A meaningful choice that reflects your values, or a bond that asks for honesty.","Misalignment or indecision. Check whether your actions match what you value.","Gemini"),
("The Chariot","determination,drive,direction","Willpower and focus move you forward. Hold the reins steady.","Losing direction, or pushing too hard without a plan.","Cancer"),
("Strength","courage,patience,compassion","Quiet courage and gentleness handle what force cannot.","Self-doubt or running on empty. Rebuild confidence in small steps.","Leo"),
("The Hermit","solitude,reflection,inner guidance","Step back to think. Time alone can show you what matters.","Isolation or avoiding reflection. Balance solitude with connection.","Virgo"),
("Wheel of Fortune","cycles,change,perspective","Things turn in cycles. Adapt to change and look for what it offers.","Resisting change or feeling stuck in a loop. Look for what you can influence.","Jupiter"),
("Justice","fairness,truth,accountability","Weigh the facts honestly. Clear, fair choices bring balance.","Bias, dodging responsibility, or an unbalanced view.","Libra"),
("The Hanged Man","pause,surrender,new angle","Stopping to see differently can unlock a stuck situation.","Stalling without purpose. Ask whether waiting is still helping.","Water"),
("Death","endings,transition,release","One chapter closes so another can begin. Let go of what has run its course.","Clinging to the past or fearing a needed change.","Scorpio"),
("Temperance","balance,patience,moderation","Blend opposing needs with patience. Steady, measured steps work best.","Excess or impatience. Look for where things are out of balance.","Sagittarius"),
("The Devil","attachment,habit,shadow","Notice what holds you, whether a habit, a belief or a dependency, and how much choice you really have.","Loosening a grip. Awareness is the first step toward freedom.","Capricorn"),
("The Tower","upheaval,revelation,reset","A sudden shake-up reveals what was not stable. Clear ground makes room to rebuild.","Fear of change or a slow-burning problem. Face it rather than wait.","Mars"),
("The Star","hope,renewal,calm","Gentle hope returns after a hard stretch. Rest and trust a slow recovery.","Doubt or low motivation. Be kind to yourself and keep small hopes alive.","Aquarius"),
("The Moon","uncertainty,dreams,intuition","Things are not fully clear. Move carefully and notice your fears and instincts.","Confusion lifting, or anxiety that needs grounding.","Pisces"),
("The Sun","joy,vitality,clarity","Warmth, confidence and openness. Enjoy what is going well.","Dimmed enthusiasm or too much ego. Look for small sources of light.","Sun"),
("Judgement","reflection,renewal,calling","A moment of honest review. Forgive the past and answer your inner call.","Self-criticism or avoiding a necessary decision.","Fire"),
("The World","completion,wholeness,achievement","A cycle completes. Take stock of how far you have come.","Loose ends or a finish that feels out of reach. One last step remains.","Saturn"),
]

SUITS = {
 "wands": ("Wands","Fire","passion, action and ambition"),
 "cups": ("Cups","Water","feelings, relationships and intuition"),
 "swords": ("Swords","Air","thoughts, truth and conflict"),
 "pentacles": ("Pentacles","Earth","work, money and the material world"),
}
RANKS = ["Ace","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Page","Knight","Queen","King"]

# (keywords, upright, reversed) per suit, ranks Ace..King
MINORS = {
"wands": [
("spark,inspiration,new energy","A burst of enthusiasm and a chance to start something bold.","Low energy or a false start. Nurture the idea before you rush."),
("planning,choices,vision","You stand at the edge of what is familiar. Decide where to aim.","Fear of leaving comfort, or plans that stay on paper."),
("foresight,progress,expansion","Early efforts are moving. Look further ahead and keep going.","Delays or a narrow view. Widen your outlook."),
("celebration,stability,home","A moment of rest and shared joy after effort.","Unease at home or a celebration that feels hollow."),
("competition,friction,debate","Clashing ideas and rivalry. Competition can sharpen you if kept friendly.","Avoiding conflict, or tension turning inward."),
("recognition,progress,confidence","Public success or a boost of confidence for your efforts.","Self-doubt or craving praise. Measure success on your own terms."),
("defence,perseverance,standing firm","You hold your ground. Stay firm on what you believe.","Feeling overwhelmed or giving up too soon."),
("speed,movement,messages","Things move fast. Act promptly and keep communication open.","Delays or scattered effort. Slow down to regroup."),
("resilience,boundaries,last push","Tired but nearly there. Draw on your resilience.","Burnout or stubbornness. Rest may be wiser than another round."),
("burden,responsibility,overload","You are carrying a lot. Consider what you can set down.","Dropping a burden, or struggling to ask for help."),
("curiosity,enthusiasm,exploration","A spirited newcomer, eager to explore and try ideas.","Impatience or half-finished projects."),
("adventure,energy,impulse","Bold, restless energy that charges ahead.","Recklessness or frustration. Think before you leap."),
("warmth,confidence,charisma","Confident, welcoming and driven. Lead by inspiring.","Insecurity or jealousy. Reconnect with your own spark."),
("vision,leadership,boldness","A natural leader with a clear vision.","Domineering or impulsive leadership."),
],
"cups": [
("openness,new feelings,compassion","An opening of the heart. Welcome kindness and emotional renewal.","Feelings held back. Allow yourself to feel."),
("connection,partnership,mutual respect","A balanced bond built on respect and shared feeling.","Imbalance or miscommunication in a relationship."),
("friendship,celebration,community","Joy shared with others. Enjoy good company.","Overindulgence, or feeling left out."),
("apathy,contemplation,reevaluation","Boredom or withdrawal. Ask what you truly want.","Waking up to new options after a dull patch."),
("loss,regret,grief","Focus on what is lost. Remember that some cups still stand.","Moving on, forgiveness and slowly turning toward what remains."),
("nostalgia,innocence,kindness","Memories and gentle generosity. Revisit the past with warmth.","Stuck in the past, or looking back instead of ahead."),
("daydreams,options,illusion","Many possibilities and some fantasy. Sort the real from the imagined.","Clarity arrives, or choices that overwhelm."),
("walking away,seeking more,moving on","Leaving something that no longer satisfies in search of meaning.","Aimless drifting, or fear of leaving."),
("contentment,satisfaction,gratitude","A sense of fulfilment. Appreciate what you have.","Smugness or a wish that is not as satisfying as expected."),
("harmony,family,fulfilment","Emotional fulfilment and a sense of belonging.","Strained bonds, or values that do not quite line up."),
("sensitivity,imagination,openness","A tender, creative message. Listen to your feelings.","Moodiness or emotional immaturity."),
("romance,charm,idealism","A dreamer who follows the heart. Offers or invitations may come.","Unrealistic ideas or mixed signals."),
("empathy,intuition,care","Deeply caring and intuitive. Look after yourself too.","Emotional overwhelm or neglecting your own needs."),
("emotional balance,diplomacy,calm","Mature, steady and compassionate. Keep calm under pressure.","Suppressed feelings or moodiness hiding behind composure."),
],
"swords": [
("clarity,truth,breakthrough","A clear idea cuts through confusion. Speak and think plainly.","Muddled thinking or harsh words."),
("stalemate,indecision,guarded","A hard choice you are avoiding. Remove the blindfold when ready.","Information comes to light, or indecision drags on."),
("heartache,sorrow,honesty","Painful truth or sadness. Acknowledge it so it can heal.","Recovery begins, or you are holding on to pain."),
("rest,recovery,retreat","Pause and recharge. Rest is productive.","Restlessness or returning to action too soon."),
("conflict,tension,hollow wins","A fight that costs more than it gains. Choose your battles.","Making peace, or lingering resentment."),
("transition,moving on,calmer waters","A slow move away from trouble. Healing is underway.","Resistance to change, or unresolved baggage."),
("strategy,secrecy,caution","Think carefully; a sly approach needs honesty about its cost.","Coming clean, or a plan that backfires."),
("restriction,fear,feeling trapped","You feel stuck, though options may be more open than they seem.","Freeing yourself, and seeing choices again."),
("anxiety,worry,sleepless nights","Worry looms large. Share it with someone you trust.","Fears easing, or anxiety that needs support."),
("endings,exhaustion,rock bottom","A painful chapter ends. The only direction now is forward.","Recovery begins, or you cling to the past."),
("curiosity,vigilance,ideas","A sharp, inquisitive mind. Ask questions and gather facts.","Gossip, haste or scattered thoughts."),
("ambition,haste,directness","Driven and quick to act. Watch for bluntness.","Burning out, or acting without thinking."),
("clarity,independence,honesty","Clear-eyed and fair. Speak the truth kindly.","Coldness or being overly critical."),
("intellect,authority,reason","Logical, principled and decisive. Seek fairness.","Rigid thinking or misuse of power."),
],
"pentacles": [
("opportunity,prosperity,foundations","A seed of opportunity in work or money. Plant it carefully.","A missed chance or poor planning."),
("balance,juggling,adaptability","Juggling priorities with flexibility. Keep your rhythm.","Overcommitting or disorganisation."),
("teamwork,craft,skill","Skilled collaboration. Good work grows through cooperation.","Poor teamwork or work below your usual standard."),
("security,saving,control","Holding on to what you have. Security is good; watch for clinging.","Generosity returns, or tight control loosens."),
("hardship,worry,feeling left out","A lean time. Help exists if you reach for it.","Recovery, or refusing to ask for support."),
("generosity,sharing,fairness","Giving and receiving in balance. Be fair with resources.","Strings attached, or one-sided exchange."),
("patience,assessment,long view","Pause to review your efforts. Growth takes time.","Impatience or doubting your progress."),
("diligence,mastery,practice","Steady, focused work builds skill.","Perfectionism or repetitive work with no purpose."),
("self-reliance,comfort,reward","Enjoy what your effort has built.","Overwork, or comfort that feels empty."),
("legacy,family,lasting security","Long-term stability, family and shared wealth.","Family friction or short-term thinking."),
("study,ambition,practicality","A hardworking student of life, eager to learn and build.","Procrastination or lack of focus."),
("reliability,persistence,routine","Dependable and thorough. Slow and steady wins.","Stubbornness, boredom or perfectionism."),
("nurturing,practical,resourceful","Warm, practical and generous. Create comfort for yourself and others.","Self-neglect or smothering."),
("abundance,stability,leadership","Established, generous and secure. Lead steadily.","Greed, stubbornness or valuing money over people."),
],
}

def slug(s): return re.sub(r"[^a-z0-9]+","_",s.lower()).strip("_")

cards=[]
for i,(name,k,u,r,assoc) in enumerate(MAJORS):
    cards.append(dict(id=f"major_{i:02d}_{slug(name.replace('The ',''))}",name=name,arcana="major",
        suit=None,number=i,element=None,association=assoc,keywords=k.split(","),upright=u,reversed=r))
for s,(sname,el,theme) in SUITS.items():
    for n,rank in enumerate(RANKS):
        k,u,r=MINORS[s][n]
        cards.append(dict(id=f"{s}_{slug(rank)}",name=f"{rank} of {sname}",arcana="minor",suit=s,
            number=n+1 if n<10 else None,element=el,association=None,keywords=k.split(","),upright=u,reversed=r))

assert len(cards)==78, len(cards)
assert len({c["id"] for c in cards})==78
for c in cards:
    assert len(c["keywords"])==3 and c["upright"] and c["reversed"], c["id"]
json.dump({"deck":"Rider-Waite-Smith","version":1,"cards":cards}, open(sys.argv[1],"w"), indent=1, ensure_ascii=False)
print("wrote",len(cards),"cards")
