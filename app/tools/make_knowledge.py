#!/usr/bin/env python3
"""Writes assets/cards/knowledge.json: richer, original card knowledge (schema v2)
for the 22 Major Arcana. Minor cards fall back to cards.json until written.

All wording is original. Tradition (what a card stands for) is not copyrightable;
phrasing of guidebooks is, so do not paste from books. Imagery notes describe the
public-domain 1909 Rider-Waite-Smith pictures. Reflective, never predictive.
Run: python3 tools/make_knowledge.py
"""
import json, pathlib

def card(essence, imagery, why, core, light, shadow, love, work, question, rcore, modes, rquestion):
    return {
        "essence": essence, "imagery": imagery, "why": why,
        "upright": {"core": core, "light": light, "shadow": shadow, "love": love, "work": work, "question": question},
        "reversed": {"core": rcore, "modes": modes, "question": rquestion},
    }

K = {}
K["major_00_fool"] = card(
 "The step you take before you feel ready.",
 "A traveller stands at the edge of a cliff under a bright sun, head tilted up and not looking down. A small bundle hangs on a stick, a white rose is in one hand, and a little white dog bounds at the heel. Mountains rise far behind.",
 "Zero is the number of potential, before anything has been counted, so this card is about starting with nothing proven. The cliff edge is the decision point. The upturned gaze reads as trust rather than planning, the light bundle as travelling without baggage, and the dog as instinct urging you on.",
 "A beginning whose result cannot be known yet, and an invitation to move anyway.",
 "curiosity, play, willingness to be a beginner, trust", "enthusiasm that skips the basics",
 "Openness to meeting a person or an experience without a script; in an existing relationship, trying something new together.",
 "Starting an unproven project, a change of direction, saying yes before you feel qualified.",
 "What would I start if I accepted that I will be clumsy at first?",
 "The energy of beginning is present but held back, rushed or pointed nowhere.",
 ["Blocked: hesitation at the edge, always preparing.", "Excess: the leap without a look at the ground.", "Inward: a plan you keep private because saying it makes it real."],
 "Am I waiting for certainty that will not arrive, or moving so fast I am not actually choosing?")
K["major_01_magician"] = card(
 "You already hold what you need to begin.",
 "A figure in a white robe and red cloak raises one wand to the sky and points the other hand to the ground. An infinity sign floats above the head. On the table before the figure lie a cup, a sword, a wand and a pentacle, and roses and lilies bloom below.",
 "One is the number of a single point of focus. The four tools on the table stand for the four suits, so every kind of resource is within reach. The raised and lowered hands are commonly read as bringing an idea down into the world. Mercury, the card's usual planet, points to skill and communication.",
 "Focus turns what is possible into something real. You have more to work with than you may think.",
 "skill, focus, initiative", "cleverness without sincerity, many tricks and little follow-through",
 "Saying plainly what you want and meaning it; sincerity over performance.",
 "Using your skills on purpose, starting a project with a plan.",
 "What do I already have that I am not using?",
 "Skill and focus are scattered, held back, or used for show.",
 ["Blocked: knowing what to do and not starting.", "Excess: promising more than you deliver.", "Inward: a talent kept private."],
 "Where is my attention going instead of where I say I want it?")
K["major_02_high_priestess"] = card(
 "What you sense before you can explain it.",
 "A woman in blue robes sits between a black pillar and a white pillar marked with the letters B and J. A crescent moon rests at her feet and a scroll is half hidden in her lap. Behind her hangs a curtain patterned with pomegranates.",
 "Two is the number of pairs and thresholds. The pillars mark a doorway between opposites, and the curtain hides what lies beyond it. The Moon, her usual association, is the traditional symbol of intuition and what is not yet visible.",
 "Stillness before deciding: listening to what is unspoken, in the situation and in you.",
 "intuition, patience, discretion", "secrecy, holding back too long",
 "Noticing what is left unsaid between people, and what you have not admitted to yourself.",
 "Gathering information before acting; trusting a quiet read of the room.",
 "What do I already sense but have not said out loud?",
 "Intuition is drowned out, or secrets are kept too tightly.",
 ["Blocked: noise and busyness over the inner voice.", "Inward: feelings hidden even from yourself.", "Excess: overthinking, reading too much into small signs."],
 "When did I last go quiet enough to hear what I think?")
K["major_03_empress"] = card(
 "Growth that comes from care.",
 "A woman in a flowing gown patterned with pomegranates sits on cushions in a field of ripe wheat. She wears a crown of stars and holds a sceptre. A heart-shaped shield with the symbol of Venus rests beside her, and a stream and a forest lie behind.",
 "Three is the number of growth and first results. Wheat, water and forest show nature at its fullest. Venus, her usual planet, points to love, pleasure and the senses.",
 "Nurture, creativity and enjoyment: things grow where they are tended.",
 "generosity, creativity, comfort", "smothering, overindulgence",
 "Warmth and care, giving and receiving; learning to let yourself be looked after.",
 "A creative project ripening, caring for a team or a process.",
 "What in my life needs tending rather than pushing?",
 "Care is blocked, overdone, or neglected, including care for yourself.",
 ["Blocked: a creative dry spell.", "Excess: over-giving or smothering.", "Fading: your own needs left last."],
 "Am I giving from fullness, or from habit?")
K["major_04_emperor"] = card(
 "Order that protects and builds.",
 "A bearded ruler in red robes over armour sits on a stone throne with ram heads on its arms. He holds an ankh-topped sceptre and an orb. Bare mountains rise behind him.",
 "Four is the number of structure and stability. The ram belongs to Aries, the first sign, linked with initiative. The barren mountains suggest authority built on discipline rather than comfort.",
 "Structure, boundaries and responsibility: using order to look after what matters.",
 "leadership, stability, clear limits", "rigidity, control",
 "Clear commitments and steadiness; where firmness turns into control.",
 "Setting up systems and rules, taking responsibility for an outcome.",
 "What structure would make this situation steadier?",
 "Structure turns into rigidity, or falls away.",
 ["Excess: control and stubbornness.", "Deficit: no boundaries, no plan.", "Inward: carrying authority uneasily."],
 "Where am I holding on tightly because I fear losing control?")
K["major_05_hierophant"] = card(
 "Learning from a shared tradition.",
 "A robed figure in a triple crown sits between two grey pillars, one hand raised in blessing. Two crossed keys lie at his feet and two figures kneel in front of him.",
 "The Hierophant is the teacher of established ways. The pillars and keys point to a doorway to knowledge that is passed on in a community. Taurus, his usual sign, is steady and loyal to what has been proven.",
 "Belonging to a tradition, a group or a teacher, and learning the established way first.",
 "mentorship, shared values, commitment", "conformity, doing it because it has always been done",
 "Shared values and rituals that hold people together.",
 "Formal learning, mentors, working inside an institution or a recognised path.",
 "Which tradition or teacher is serving me, and which am I following out of habit?",
 "Inherited rules are being questioned, or are stuck in place.",
 ["Releasing: stepping away from convention.", "Blocked: unwilling to learn from others.", "Excess: rules held as dogma."],
 "Whose rules am I living by?")
K["major_06_lovers"] = card(
 "A choice that asks you to be honest about your values.",
 "A man and a woman stand unclothed under a bright sun. An angel spreads its arms above them. Behind the woman is a tree with a snake and behind the man a tree of flames.",
 "Six is the number of exchange and harmony. Gemini, the twins, is the sign of duality and choice. The angel suggests a wider view than either person has alone. Although it is often read as romance, the heart of the card is a choice made in line with what you value.",
 "A meaningful choice or connection that asks you to act in line with your values.",
 "honesty, harmony, commitment", "indecision, choosing in order to please",
 "Honest connection, and whether your actions match what you say you want.",
 "A choice or partnership that fits your values, not only your convenience.",
 "What would I choose if I were fully honest about what matters to me?",
 "Choices are delayed, or values and actions are out of tune.",
 ["Blocked: putting off the decision.", "Excess: leaning too hard on another person's view.", "Fading: a sense of drifting apart."],
 "Where am I saying yes while meaning no?")
K["major_07_chariot"] = card(
 "Moving forward by holding opposing pulls together.",
 "An armoured figure stands upright in a chariot under a canopy of stars. A black sphinx and a white sphinx rest in front of it, and the figure holds no reins. A city lies behind.",
 "Seven is the number of tests. The two sphinxes face different ways, so the driver steers by will and focus, not by force. Cancer, the usual sign, gives a protective shell around a determined aim.",
 "Disciplined drive: you keep moving by holding competing pulls in line.",
 "determination, focus, momentum", "force without direction, running over others",
 "Choosing where to put your energy and sticking with it.",
 "Pushing a project through to the end; staying focused under pressure.",
 "What am I steering, and where do I want it to go?",
 "Drive is scattered, stalled or turned aggressive.",
 ["Blocked: stuck without direction.", "Excess: forcing things, aggression.", "Inward: pulled two ways at once."],
 "Am I steering, or being dragged?")
K["major_08_strength"] = card(
 "Courage that is gentle.",
 "A woman in white, with an infinity sign above her head, calmly closes the mouth of a lion. She wears a garland of flowers and mountains rise behind.",
 "In this deck Strength is numbered eight (Justice is eleven). Eight is the number of steady effort. The picture shows strength as patience rather than force: the lion is not beaten but befriended. Leo, her usual sign, is the lion.",
 "Quiet courage: meeting a strong feeling with patience and kindness instead of a fight.",
 "patience, resilience, self-compassion", "self-doubt, pushing feelings down",
 "Staying steady and gentle when emotions run high.",
 "Keeping calm under pressure; leading by example.",
 "What would patience look like here?",
 "Strength is drained, or force takes the place of gentleness.",
 ["Fading: running low on energy.", "Blocked: self-doubt.", "Excess: trying to tame a feeling by force."],
 "What am I trying to force that needs gentleness?")
K["major_09_hermit"] = card(
 "Stepping back to find your own answer.",
 "An old figure in a grey cloak stands on a snowy peak. One hand holds a lantern with a six-pointed star inside and the other a staff.",
 "Nine is the number of near-completion and solitude. The lantern lights only the next few steps, which is how inner guidance often works. Virgo, the usual sign, is careful and discerning.",
 "Time apart to hear your own thoughts and decide what matters.",
 "wisdom, focus, chosen solitude", "isolation, avoiding people or choices",
 "Time alone to understand what you want; sharing it when ready.",
 "Deep focus, research, finding a mentor or becoming one.",
 "What do I hear when everything gets quiet?",
 "Solitude turns into isolation, or you cannot be alone with your thoughts.",
 ["Excess: withdrawing too far.", "Blocked: restless, unable to be still.", "Fading: coming back toward other people."],
 "Is this solitude restoring me or hiding me?")
K["major_10_wheel_of_fortune"] = card(
 "A cycle turning, with you inside it.",
 "A great wheel marked with letters and symbols turns in the sky. A snake descends on one side and a jackal-headed figure rises on the other, while a sphinx holding a sword sits on top. Four winged figures, each reading a book, float in the corners among clouds.",
 "Ten is the number of a completed cycle. Jupiter, the usual planet, is linked with expansion and luck. The picture is about rising and falling, and about what stays steady while the wheel moves.",
 "Circumstances shift in cycles. You cannot stop the wheel, but you can choose how to meet it.",
 "perspective, timing, a new chapter", "feeling at the mercy of events",
 "Phases and patterns in relationships; seeing your own part in them.",
 "Changing circumstances; staying adaptable.",
 "What cycle am I in, and what is it asking of me?",
 "You resist a change, or feel stuck in a loop.",
 ["Blocked: stuck in a repeating pattern.", "Fading: a cycle winding down.", "Inward: change happening inside first."],
 "What pattern keeps repeating, and what is my part in it?")
K["major_11_justice"] = card(
 "An honest look at the facts, and at your part in them.",
 "A crowned figure in a red robe sits between two pillars. One hand holds an upright sword and the other a pair of scales. A purple veil hangs behind.",
 "In this deck Justice is numbered eleven. The scales weigh, the sword cuts through, and the figure is seated, so the card is about calm judgment and cause and effect. Libra, the usual sign, is the sign of the scales.",
 "Seeing a situation fairly and owning your choices.",
 "fairness, clarity, accountability", "harsh judgment, rigidity",
 "An honest conversation about what each person is doing.",
 "Decisions based on honest facts, treating people fairly.",
 "What would a fair account of this situation include?",
 "Bias, avoiding consequences, or judging yourself too harshly.",
 ["Blocked: avoiding accountability.", "Excess: harsh judging of others.", "Inward: the scales are unfair to yourself."],
 "Am I being fair to myself?")
K["major_12_hanged_man"] = card(
 "A pause that shows you something new.",
 "A figure hangs upside down by one foot from a living wooden frame, hands behind the back and one leg bent. A halo of light surrounds the calm face.",
 "Twelve closes a full set, and the card is about stopping rather than doing. The hanging is voluntary; the face is peaceful. Water, the usual element, suggests letting go of control and seeing from a new angle.",
 "Stopping on purpose lets you see the situation from another side.",
 "patience, perspective, letting go", "stalling, feeling like a martyr",
 "Pausing to see a situation from the other person's side, or your own.",
 "Waiting for the right moment; a change of viewpoint.",
 "What do I see if I stop trying to fix this?",
 "The pause has become delay, or a sacrifice that serves no one.",
 ["Blocked: stalling.", "Excess: a martyr role.", "Releasing: ending a pause and getting ready to move."],
 "Am I waiting for a reason, or avoiding a choice?")
K["major_13_death"] = card(
 "An ending that is already underway.",
 "A skeleton in black armour rides a white horse and carries a black banner with a white flower. A bishop pleads, a child offers flowers, a king lies fallen and a young woman looks away. In the distance a river runs and the sun rises between two towers.",
 "The picture is about how people respond to an ending: the king cannot stop it, the bishop's prayer does not slow it, the child meets it with curiosity. The flower on the banner is commonly read as life continuing, and the sunrise as what comes after. Thirteen follows a full set of twelve, so tradition treats it as the number of transformation. It is not a prediction of physical death.",
 "A chapter, role, habit or belief has finished, and holding on now costs more than letting go.",
 "closure, clearing out, relief", "grief, especially if the ending was not your choice",
 "A pattern or phase of a relationship changing; putting down an old story about someone or about yourself.",
 "The end of a role, project or way of working; making room for something different.",
 "What has already ended that I am still acting as if it has not?",
 "The ending is being resisted, dragged out or only partly accepted.",
 ["Blocked: clinging past the natural end.", "Fading: an ending that drags on because nobody names it.", "Inward: quietly knowing something is over and not saying so yet."],
 "What would I have to admit is over in order to move?")
K["major_14_temperance"] = card(
 "Finding the middle path.",
 "An angel with large wings stands with one foot in water and one on land, pouring liquid between two cups. A path winds toward a glow between distant mountains, and irises grow nearby.",
 "Fourteen follows the turning point of the Majors and brings blending and recovery. Pouring between cups is about combining opposites at a steady pace. Sagittarius, the usual sign, adds the long view.",
 "Blending opposites patiently and keeping a steady pace.",
 "balance, patience, moderation", "lukewarm avoidance of commitment",
 "Patience and giving each other room to differ.",
 "A sustainable pace, collaboration, combining skills.",
 "What two things in my life need blending rather than choosing between?",
 "Things are out of balance, or pushed to extremes.",
 ["Excess: overdoing it.", "Deficit: impatience, wanting results now.", "Blocked: cannot find a middle way."],
 "Where have I tipped too far to one side?")
K["major_15_devil"] = card(
 "Seeing what holds you, and how loosely.",
 "A horned figure perches on a block, one hand raised and the other holding a torch. A man and a woman, each with small horns and a tail, stand chained at the neck to the block. The chains are loose enough to lift off.",
 "Fifteen sits in the third act of the Majors, where hidden pulls come into view. Capricorn, the usual sign, is earthly and practical, and the card is about material attachment, habit and the shadow side. The loose chains suggest the hold is partly chosen. It is not a literal devil.",
 "Seeing a habit, attachment or fear that you could loosen once you name it.",
 "honesty about desire, naming what holds you", "feeling stuck, repeating a pattern (if a habit is affecting your health, a professional can help)",
 "Patterns of dependence or control in how people relate; noticing your own part.",
 "A job or arrangement kept for comfort rather than meaning.",
 "What am I holding that I could put down?",
 "A hold is loosening, or you are avoiding seeing it.",
 ["Releasing: slipping out of a grip.", "Blocked: denial.", "Inward: quietly aware but not yet acting."],
 "What would I do if I trusted that I could step out?")
K["major_16_tower"] = card(
 "What was never stable comes down.",
 "A tall tower on a crag is struck by lightning. The crown flies off, flames burst from the windows and two figures fall. The sky is dark.",
 "Sixteen is the number of the break. Mars, the usual planet, is the planet of sudden force. The tower is a structure built on a weak base, and the lightning is revelation as much as damage.",
 "Something built on shaky ground comes down, clearing space for something more honest.",
 "revelation, release, a more honest start", "shock, fear of loss",
 "Sudden honesty or a change in a pattern; reacting to news.",
 "Plans that no longer hold; rebuilding a different way.",
 "What was never stable that I have been propping up?",
 "The shock is being avoided, or you are in its aftermath.",
 ["Blocked: resisting something that is already coming apart.", "Fading: a slow unravelling.", "Inward: a private crisis."],
 "What small honest change could I make before things have to break?")
K["major_17_star"] = card(
 "Quiet hope after a hard stretch.",
 "A woman kneels beside a pool, pouring water from two jugs, one onto land and one into the pool. A large eight-pointed star shines above her with seven smaller ones, and a bird perches in a tree behind.",
 "Seventeen comes right after the Tower, so this is calm after upheaval. The two jugs are about giving back to the earth and to yourself. Aquarius, the usual sign, is the water-bearer, linked with hope and openness.",
 "Gentle renewal and trust coming back after difficulty.",
 "hope, healing, honesty", "wishing without acting, feeling detached",
 "Gentleness, starting to trust again.",
 "Renewed motivation; a clearer sense of what you want to work toward.",
 "What helps me feel hopeful, and how can I do more of it?",
 "Hope is dimming, or has become vague.",
 ["Fading: discouragement.", "Blocked: no light in sight.", "Excess: wishing without acting."],
 "What small thing could bring back a bit of trust?")
K["major_18_moon"] = card(
 "Things are not yet clear.",
 "A full moon with a face shines between two towers. A dog and a wolf howl at it, and a crayfish crawls from a pool onto a winding path that leads into the distance.",
 "Eighteen sits near the end of the journey, where the unconscious is loud. The moon gives light, but not enough to see clearly. Pisces, the usual sign, is dreamy and sensitive.",
 "Feelings and imagination colour what you see, so take your time and gather more light.",
 "intuition, creativity, imagination", "fear, projection, confusion",
 "Unclear feelings, or imagining what another person thinks.",
 "Working with incomplete information; avoiding hasty conclusions.",
 "What am I afraid of that has not actually happened?",
 "The fog is lifting, or the confusion is deepening.",
 ["Fading: things start to become clear.", "Excess: anxiety spiralling.", "Inward: a fear kept hidden."],
 "What would look different in daylight?")
K["major_19_sun"] = card(
 "Plain, uncomplicated warmth.",
 "A child on a white horse holds a red banner under a large sun. Sunflowers rise over a wall behind.",
 "Nineteen is near the end of the journey, and the picture is open and bright, with nothing hidden. The Sun is the card's usual planet: vitality and clarity.",
 "Warmth, clarity and simple joy.",
 "optimism, vitality, openness", "overconfidence, ignoring complexity",
 "Openness and playfulness with the people you trust.",
 "Feeling confident and clear about work you care about.",
 "What brings me plain, uncomplicated joy?",
 "The warmth is dimmed or forced.",
 ["Blocked: clouds in the way.", "Excess: forced positivity.", "Fading: tiredness."],
 "Where am I pretending to be brighter than I feel?")
K["major_20_judgement"] = card(
 "A call to look back and begin again.",
 "An angel blows a trumpet from the clouds. Below, figures with raised arms rise from open coffins. Snowy mountains stand behind.",
 "Twenty is the number of the awakening before completion. The trumpet is a call, and the rising figures are people answering. The card is about review and renewal, not a verdict handed down.",
 "A moment of reckoning and renewal: hearing a call to live differently.",
 "awakening, forgiveness, purpose", "harsh self-judgment",
 "Forgiveness, and an honest look at a pattern.",
 "Reassessing a path; a sense of calling.",
 "What is calling me that I have been postponing?",
 "Doubt, ignoring the call, or being hard on yourself.",
 ["Blocked: ignoring what you hear.", "Excess: harsh self-criticism.", "Inward: a private reckoning."],
 "Can I forgive myself enough to move on?")
K["major_21_world"] = card(
 "A cycle complete.",
 "A dancing figure wrapped in a light scarf holds two wands inside a large laurel wreath. In the four corners are an angel, an eagle, a bull and a lion.",
 "Twenty-one is the last of the Majors, so this is completion. The wreath is a closed loop and the dancing figure moves freely inside it. The four corner figures are tied to the four suits. Saturn, the usual planet, is linked with finishing and limits.",
 "Completion and wholeness, with the next cycle waiting.",
 "completion, integration, satisfaction", "reluctance to finish or to move on",
 "Feeling whole in yourself, and sharing it.",
 "Finishing a project; taking in what you have learned.",
 "What have I finished that deserves to be acknowledged?",
 "Something is almost complete but not quite finished.",
 ["Blocked: the last step is missing.", "Fading: closure is near.", "Inward: not quite ready to let go."],
 "What is the last step I keep avoiding?")

from knowledge_courts import add_courts
add_courts(K, card)

out = {"version": 2, "note": "Original wording. Majors and courts; pips use cards.json until written.", "cards": K}
p = pathlib.Path(__file__).resolve().parent.parent / "assets" / "cards" / "knowledge.json"
p.write_text(json.dumps(out, indent=1, ensure_ascii=False) + "\n")
print("wrote", p, len(K))
